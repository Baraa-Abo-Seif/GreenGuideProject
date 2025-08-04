import nltk
import base64
import os
from fastapi import File
from typing import Literal, TypedDict
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import NLTKTextSplitter
from langchain_chroma import Chroma
from langchain_core.messages import SystemMessage, HumanMessage
from langchain_core.prompts import ChatPromptTemplate, HumanMessagePromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough, Runnable
from langchain_community.tools.tavily_search import TavilySearchResults
from langgraph.graph import END, StateGraph, START
from langchain.agents import initialize_agent, AgentType
from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings

nltk.download('punkt')
nltk.download('punkt_tab')
nltk.download('averaged_perceptron_tagger')

class AgentState(TypedDict):
    question: str
    image_path: str
    image_summary: str
    response: str

class ImageRunnable(Runnable):
    def __init__(self, image_data):
        self.image_data = image_data

    def invoke(self, inputs, config=None):
        inputs["image_summary"] = self.image_data
        return inputs

class RAG:
    def __init__(self, folder_path, domain):
        key = "AIzaSyBkeAaLuUE8mkyDSNdNc6ULcVTqjfcx-ro"
        self.chat_model = ChatGoogleGenerativeAI(google_api_key=key, model="gemini-2.0-flash")
        self.domain = domain
        self.pages = self.load_all_pdfs_from_folder(folder_path)

        self.text_splitter = NLTKTextSplitter(chunk_size=500, chunk_overlap=100)
        self.chunks = self.text_splitter.split_documents(self.pages)

        self.embedding_model = GoogleGenerativeAIEmbeddings(google_api_key=key, model="models/embedding-001")

        self.db = Chroma.from_documents(self.chunks, self.embedding_model, persist_directory="./chroma_db_")
        

        self.db_connection = Chroma(persist_directory="./chroma_db_", embedding_function=self.embedding_model)
        self.retriever = self.db_connection.as_retriever(search_kwargs={"k": 1})

        self.web_search_tool = TavilySearchResults(k=3, tavily_api_key="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")

        self.graph = self._build_graph()

    def load_all_pdfs_from_folder(self, folder_path):
        """Loads and splits all PDF documents from a folder."""
        all_pages = []
        for filename in os.listdir(folder_path):
            if filename.lower().endswith(".pdf"):
                file_path = os.path.join(folder_path, filename)
                loader = PyPDFLoader(file_path)
                pages = loader.load_and_split()
                all_pages.extend(pages)
        return all_pages
    
    def format_docs(self, docs):
         return "\n\n".join(doc.page_content for doc in docs)
    
    def agent(self, state: AgentState):
        question = state["question"]
        return {"question": question, "doc": self.format_docs(self.chunks)}
  
    def message(self, state: AgentState):
         return {"response": f"Sorry, the question or image is not related to  {self.domain}."}
    
    def has_image(self, state: AgentState) -> Literal["with_image", "no_image"]:
        return "with_image" if state.get("image_path") else "no_image"
  
    def grade_documents(self, state: AgentState) -> Literal["one", "two", "three"]:
        image_summaries = state.get("image_summary")
        if not image_summaries:
            chat_template = ChatPromptTemplate.from_messages([
            SystemMessage(content=f"""You are a grader. You will assess the relationship between a question and a document within the context of the domain: {self.domain}.

        Score the input using the following criteria:
        1 → The document **directly answers** the question.
        2 → The question is **clearly about** {self.domain}, but the document does **not directly** answer it.
        3 → The question is **not related** to {self.domain} in any way.

        Important:
        - Only give a score of 3 if the question is **completely unrelated** to {self.domain}.
        - Be conservative in assigning a 3 — assume relatedness unless clearly not.

        Output ONLY a single digit: 1, 2, or 3.
        """),
            HumanMessagePromptTemplate.from_template("""
        Document:
        {context}

        Question: {question}
        """)
        ])

            output_parser = StrOutputParser()


            rag_chain = (
                {"context": self.retriever | self.format_docs, "question": RunnablePassthrough()}
                | chat_template
                | self.chat_model
                | output_parser
            )
        else:
          chat_template = ChatPromptTemplate.from_messages([
                SystemMessage(content=f"""You are a grader. Your job is to assess if the question and image summary:
        1. Are directly answerable using the provided document → Return 1
        2. Are related to {self.domain}, but the document doesn't answer them → Return 2
        3. The image summary does not contain anything related at all to {self.domain} (it does not contain any object related with {self.domain}). → Return 3
        4. The question has nothing related with {self.domain} at all → Also return 3.
        Only return the number (1, 2, or 3)"""),
                HumanMessagePromptTemplate.from_template("""
        Document:
        {context}

        Question: {question}
        Image Summary: {image_summary}
        """)
            ])
          output_parser = StrOutputParser()



          rag_chain = (
              {"context": self.retriever | self.format_docs, "question": RunnablePassthrough()}
              | ImageRunnable(image_summaries)
              | chat_template
              | self.chat_model
              | output_parser
              )


        score = rag_chain.invoke(state["question"])
        if score == "1":
            return "one"
        elif score == "2":
            return "two"
        else:
            return "three"
      
    def rewrite(self, state: AgentState):
        question = state["question"]
        image_summary = state["image_summary"]
        if not image_summary:
            msg = [
            HumanMessage(
                content=f"""Look at the question and the image summary.
                 rewrite the question for web searching.
                 if the question contains Arabic words, rewrite it in Arabic.
                 if all question words are in English, rewrite it in English.

                 -------
                 Question: {question}

                Just give the new question.

                """

            )
        ]
        else:
          msg = [
            HumanMessage(
                content=f"""Look at the question and the image summary.
                 Write a new question for web searching that combines both the original question and the image summary.

                 -------
                 Question: {question}
                 -------
                 Image Summary: {image_summary}
                 -------
                """
            )
        ]
        response = self.chat_model.invoke(msg)
        print(f"Rewritten question: {response.content}")
        return {"question": response.content}

    
    def search(self, state: AgentState):
        question = state["question"]
        # Prepend system-like instruction manually
        prompt = (
        f"You are an expert AI assistant specializing in {self.domain} in Jordan. "
        "Answer in the language of the question. be helpful and polite.\n"
        f"Question: {question}"
    )

        agent = initialize_agent(
            tools=[self.web_search_tool],
            llm=self.chat_model,
            agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
            handle_parsing_errors=True,
            verbose=True,
        )

        # Use .invoke() instead of .run()
        response = agent.invoke(prompt)
        return {"response": response["output"]}


    def summarize_image(self, state: AgentState):
        image_path = state.get("image_path", "")
        base64_image = base64.b64encode(image_path.file.read()).decode("utf-8")

        prompt = """You are an assistant tasked with summarizing images for retrieval. \
        These summaries will be embedded and used to retrieve the raw image. \
        Give a concise summary of the image that is well optimized for retrieval."""

        image_data_uri = f"data:image/jpeg;base64,{base64_image}"

        message = HumanMessage(
        content=[
            {"type": "text", "text": prompt},
            {"type": "image_url", "image_url": {"url": image_data_uri}},
        ],
        )

        image_summaries = self.chat_model.invoke([message])
        print(f"Image summary: {image_summaries.content}")
        return {"image_summary": image_summaries.content}

    def generate(self, state: AgentState):
        question = state["question"]
        image_summary = state.get("image_summary", "")
        if not image_summary:
            prompt = ChatPromptTemplate.from_messages([
                        SystemMessage(content=f"""You are an expert AI assistant specializing in {self.domain} in Jordan.
            Use the provided context to answer the question with details.
            Answer in the language of the question. Give long answers.
            If the context lacks relevant data, fall back to your general knowledge — but clearly state that the information is inferred or general when doing so.
            Keep answers focused and practical. Avoid phrases like 'Based on the document'."""),

                        HumanMessagePromptTemplate.from_template("""
            Context: {context}
            Question: {question}
            """)
                    ])

            output_parser = StrOutputParser()



            rag_chain = (
                {"context": self.retriever | self.format_docs, "question": RunnablePassthrough()}
                | prompt
                | self.chat_model
                | output_parser
                )
            return {"response": rag_chain.invoke(question)}
        else:
          prompt = ChatPromptTemplate.from_messages([
                        SystemMessage(content=f"""You are an expert AI assistant specializing in {self.domain} in Jordan.
            Use the provided context and image summary to answer the question directly. **Answer in the language of the question**.
            If the context does not explicitly mention the type of object in the image, but contains related or similar objects, provide a useful answer based on that.
            If the context lacks relevant data, fall back to your general knowledge — but clearly state that the information is inferred or general when doing so.
            Keep answers focused and practical. Avoid phrases like 'Based on the document'."""),

                        HumanMessagePromptTemplate.from_template("""
            Context: {context}
            Image Summary: {image_summary}
            Question: {question}
            """)
                    ])
          output_parser = StrOutputParser()

          rag_chain = (
                {"context": self.retriever | self.format_docs, "question": RunnablePassthrough()}
                | ImageRunnable(image_summary)
                | prompt
                | self.chat_model
                | output_parser
                )
          return {"response": rag_chain.invoke(question)}


    def _build_graph(self):
        workflow = StateGraph(AgentState)

        workflow.add_node("agent", self.agent)
        workflow.add_node("search", self.search)
        workflow.add_node("rewrite", self.rewrite)
        workflow.add_node("summarize_image", self.summarize_image)
        workflow.add_node("generate", self.generate)
        workflow.add_node("message", self.message)

        workflow.add_conditional_edges(
            START,
            self.has_image,
            {
                "with_image": "summarize_image",
                "no_image": "agent"
            }
        )
        workflow.add_edge("summarize_image", "agent")
        workflow.add_conditional_edges(
            "agent",
            self.grade_documents,
            {
                "one": "generate",        # related to doc
                "two": "rewrite",         # related to farming but not in doc
                "three": "message"        # not related to farming
            },
        )

        workflow.add_edge("rewrite", "search")
        workflow.add_edge("search", END)
        workflow.add_edge("message", END)
        workflow.add_edge("generate", END)

        return workflow.compile()

    def run(self, question: str, image_path: str = ""):
        initial_state = {
                "question": question,
                "image_path": image_path,
                "image_summary": "",
                "response": ""
            }
        result = self.graph.invoke(initial_state)
        return result["response"]
    

