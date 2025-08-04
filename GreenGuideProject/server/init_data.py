from sqlalchemy.orm import Session
from models import Types, Questions, Questions_Ar, Information, Information_Ar
from database import SessionLocal

def insert_types():
    db: Session = SessionLocal()
    types = [
        Types(id=1, name="Agriculture and Farming"),
        Types(id=2, name="Food and Nutrition"),
        Types(id=3, name="Nutrition for Athletes"),
        Types(id=4, name="Home Gardens"),
    ]
    for type in types:
        if not db.query(Types).filter_by(id=type.id).first():
            db.add(type)
    db.commit()
    db.close()

def insert_information():
    db: Session = SessionLocal()
    information = [
        Information(id=1, text="Organic farming methods", typeID = 1, image_path="server/assets/organic_farming_methods.png"),
        Information(id=2, text="Efficient irrigation systems", typeID = 1, image_path="server/assets/efficient_irrigation_systems.png"),
        Information(id=3,  text="Organic pest control", typeID = 1, image_path="server/assets/organic_pest_control.png"),
        Information(id=4, text="Climate-smart farming", typeID = 1, image_path="server/assets/climate_smart_farming.png"),
        Information(id=9, text="Essential vitamins guide", typeID = 2, image_path="server/assets/essential_vitamins_guide.png"),
        Information(id=10, text="Child nutrition tips", typeID = 2, image_path="server/assets/child_nutrition_tips.png"),
        Information(id=11,  text="Pregnancy diet advice", typeID = 2, image_path="server/assets/pregnancy_diet_advice.png"),
        Information(id=12, text="Importance of hydration", typeID = 2, image_path="server/assets/importance_of_hydration.png"),
        Information(id=16, text="Workout meal timing", typeID = 3, image_path="server/assets/workout_meal_timing.png"),
        Information(id=17, text="Cutting diet", typeID = 3, image_path="server/assets/cutting_diet.png"),
        Information(id=18, text="High-protein snacks", typeID = 3, image_path="server/assets/high_protein_snacks.png"),
        Information(id=19,  text="Sleep and nutrition", typeID = 3, image_path="server/assets/sleep_and_nutrition.png"),
    ]
    for info in information:
        if not db.query(Information).filter_by(id=info.id).first():
            db.add(info)
    db.commit()
    db.close()

def insert_information_ar():
    db: Session = SessionLocal()
    information = [
        Information_Ar(id=1, text="الزراعة الطبيعية", typeID = 1, image_path="server/assets/organic_farming_methods.png"),
        Information_Ar(id=2, text="ريّ بيوفر ميّ", typeID = 1, image_path="server/assets/efficient_irrigation_systems.png"),
        Information_Ar(id=3,  text="التخلص من الحشرات", typeID = 1, image_path="server/assets/organic_pest_control.png"),
        Information_Ar(id=4, text="زراعة بتتحمّل الجو", typeID = 1, image_path="server/assets/climate_smart_farming.png"),
        Information_Ar(id=9, text="فيتامينات مهمة", typeID = 2, image_path="server/assets/essential_vitamins_guide.png"),
        Information_Ar(id=10, text="أكل للأطفال", typeID = 2, image_path="server/assets/child_nutrition_tips.png"),
        Information_Ar(id=11,  text="أكل للحامل", typeID = 2, image_path="server/assets/pregnancy_diet_advice.png"),
        Information_Ar(id=12, text="شرب ميّ كفاية", typeID = 2, image_path="server/assets/importance_of_hydration.png"),
        Information_Ar(id=16, text="أكل قبل و بعد التمرين", typeID = 3, image_path="server/assets/workout_meal_timing.png"),
        Information_Ar(id=17, text="أكل للتنشيف", typeID = 3, image_path="server/assets/cutting_diet.png"),
        Information_Ar(id=18, text="سناك فيه بروتين", typeID = 3, image_path="server/assets/high_protein_snacks.png"),
        Information_Ar(id=19,  text="نوم وأكل", typeID = 3, image_path="server/assets/sleep_and_nutrition.png"),
    ]
    for info in information:
        if not db.query(Information_Ar).filter_by(id=info.id).first():
            db.add(info)
    db.commit()
    db.close()

def insert_questions():
    db: Session = SessionLocal()
    questions = [
        Questions(id=1, text="What are the risks of planting this tree in Jordan?", typeID = 1),
        Questions(id=2, text="How much water does this plant/tree need?", typeID = 1),
        Questions(id=3,  text="How can climate-smart agriculture be applied to this crop/tree?", typeID = 1),
        Questions(id=4, text="What type of fertilizer is used for this plant/tree?", typeID = 1),
        Questions(id=5, text="What diseases might affect this plant/tree?", typeID = 1),
        Questions(id=6, text="Are there any economic incentives or green investments for farming this plant in Jordan?", typeID = 1),
        Questions(id=7,  text="How does climate change affect the cultivation of this crop in Jordan?", typeID = 1),
        Questions(id=8, text="Is this plant part of Jordan's green growth strategy (2021-2025)? ", typeID = 1),
        Questions(id=9, text="What diseases may this food cause?", typeID = 2),
        Questions(id=10, text="What vitamins does this food contain?", typeID = 2),
        Questions(id=11,  text="Does this food cause overweight/obesity?", typeID = 2),
        Questions(id=12, text="Is this food suitable for diabetics?", typeID = 2),
        Questions(id=13, text="Is this food suitable for blood pressure patients? ", typeID = 2),
        Questions(id=14, text="Is this food suitable for cholesterol patients?", typeID = 2),
        Questions(id=15,  text="Is this food suitable for dyslipidemia? ", typeID = 2),
        Questions(id=16, text="Is this food suitable before exercise?", typeID = 3),
        Questions(id=17, text="Is this food suitable after exercise?", typeID = 3),
        Questions(id=18, text="Is this food healthy?", typeID = 3),
        Questions(id=19,  text="Is this food suitable for weight loss?", typeID = 3),
        Questions(id=20, text="Is this food good for building muscle?", typeID = 3),
        Questions(id=21, text="What is the percentage of protein in this food?", typeID = 3),
    ]
    for question in questions:
        if not db.query(Questions).filter_by(id=question.id).first():
            db.add(question)
    db.commit()
    db.close()

def insert_questions_ar():
    db: Session = SessionLocal()
    questions = [
        Questions_Ar(id=1, text="شو ممكن تكون مخاطر زراعة هاي الشجرة بالأردن؟", typeID = 1),
        Questions_Ar(id=2, text="قديش بتحتاج هاي النبتة/الشجرة مي؟", typeID = 1),
        Questions_Ar(id=3,  text="كيف ممكن نطبق الزراعة الذكية المناخية على هاد المحصول/الشجرة؟", typeID = 1),
        Questions_Ar(id=4, text="شو نوع السماد اللي بنستخدمه لهاي النبتة/الشجرة؟", typeID = 1),
        Questions_Ar(id=5, text="شو الأمراض اللي ممكن تصيب هاي النبتة/الشجرة؟", typeID = 1),
        Questions_Ar(id=6, text="في دعم أو استثمار من الدولة أو مشاريع خضراء لزراعة هاي النبتة بالأردن؟", typeID = 1),
        Questions_Ar(id=7,  text="كيف بتأثر التغيرات المناخية على زراعة هاد المحصول بالأردن؟", typeID = 1),
        Questions_Ar(id=8, text="هل هاي النبتة من ضمن خطة الأردن للنمو الأخضر (2021-2025)؟", typeID = 1),
        Questions_Ar(id=9, text="شو الأمراض اللي ممكن يسببها هاد الأكل؟", typeID = 2),
        Questions_Ar(id=10, text="شو الفيتامينات الموجودة في هاد الأكل؟", typeID = 2),
        Questions_Ar(id=11,  text="هل هاد الأكل بيسبب سمنة أو زيادة وزن؟", typeID = 2),
        Questions_Ar(id=12, text="هل هاد الأكل مناسب لمرضى السكري؟", typeID = 2),
        Questions_Ar(id=13, text="هل هاد الأكل مناسب للي عندهم ضغط دم؟", typeID = 2),
        Questions_Ar(id=14, text="هل هاد الأكل مناسب للي عندهم كوليسترول؟", typeID = 2),
        Questions_Ar(id=15,  text="هل هاد الأكل مناسب للي عندهم مشاكل بالدهون (الدسليبيديميا)؟", typeID = 2),
        Questions_Ar(id=16, text="هل بنفع آكله قبل التمرين؟", typeID = 3),
        Questions_Ar(id=17, text="هل بنفع آكله بعد التمرين؟", typeID = 3),
        Questions_Ar(id=18, text="هل هو أكل صحي؟", typeID = 3),
        Questions_Ar(id=19,  text="هل بيساعد هاد الأكل على تخفيف الوزن؟", typeID = 3),
        Questions_Ar(id=20, text="هل بيساعد هاد الأكل على بناء العضلات؟", typeID = 3),
        Questions_Ar(id=21, text="قديش في هاد الأكل نسبة بروتين؟", typeID = 3),
    ]
    for question in questions:
        if not db.query(Questions_Ar).filter_by(id=question.id).first():
            db.add(question)
    db.commit()
    db.close()

if __name__ == "__main__":
    insert_types()
    insert_questions()
    insert_questions_ar()
    insert_information()
    insert_information_ar()
    # pass
