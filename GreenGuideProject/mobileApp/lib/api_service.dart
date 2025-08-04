import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.227.125:8000';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/Users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      // Only decode if response is successful
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw HttpException('The email or password you entered is incorrect.');
      } else {
        throw HttpException('Oops! Something went wrong. Please try again soon.');
      }
    } on SocketException {
      throw HttpException('No internet connection. Please check your network and try again.');
    } on TimeoutException {
      throw HttpException('The server is taking too long to respond. Please try again later.');
    } on HttpException{
      throw HttpException('The email or password you entered is incorrect.');
    } catch (e) {
      throw HttpException('An unexpected error occurred. Please try again.');
    }
  }



 static Future<Map<String, dynamic>> signup(String email, String password, int typeID) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/Users/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password, 'question':'No question', 'typeID': typeID}),
          )
          .timeout(const Duration(seconds: 5));

      // Only decode if response is successful
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        throw HttpException('The email already exists.');
      } else {
        throw HttpException('Oops! Something went wrong. Please try again soon.');
      }
    } on SocketException {
      throw HttpException('No internet connection. Please check your network and try again.');
    } on TimeoutException {
      throw HttpException('The server is taking too long to respond. Please try again later.');
    } on HttpException{
      throw HttpException('The email already exists.');
    } catch (e) {
      throw HttpException('An unexpected error occurred. Please try again.');
    }
  }

  static Future<void> logout(String refreshToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/Users/logout'),
            headers: {
              'Content-Type': 'application/json',
              'refresh_token': refreshToken,
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Optionally, you could clear any local tokens here
        print("Logout successful");
      } else if (response.statusCode == 401) {
        throw HttpException('Invalid or expired refresh token.');
      } else {
        throw HttpException('Logout failed. Please try again.');
      }
    } on SocketException {
      throw HttpException('No internet connection. Please check your network and try again.');
    } on TimeoutException {
      throw HttpException('The server is taking too long to respond. Please try again later.');
    } catch (e) {
      throw HttpException('An unexpected error occurred during logout.');
    }
  }

  static Future<bool> checkToken(String accessToken) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/Users/check_token'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    ).timeout(const Duration(seconds: 5));

    return response.statusCode == 200;
  } catch (_) {
    return false; // If anything goes wrong, assume token is invalid
  }
}

static Future<String?> refreshAccessToken(String refreshToken) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Users/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'refresh_token': refreshToken,
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    }
  } catch (_) {}

  return null;
}

static Future<bool?> checkTypeID(String accessToken) async {
  try {
    final response = await http
        .get(
          Uri.parse('$baseUrl/Users/check_typeID'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['typeID_is_null']; // returns true or false
    } else {
      return null; // Handle unauthorized or unexpected response
    }
  } catch (e) {
    return null; // Handle network or parsing errors
  }
}

static Future<Map<String, dynamic>> updateUserTypeID({
  required String accessToken,
  int? typeID,
  String? question,
}) async {
  try {
    final Map<String, dynamic> body = {};
    if (typeID != null) body['typeID'] = typeID;
    if (question != null) body['question'] = question;

    final response = await http
        .put(
          Uri.parse('$baseUrl/Users/update_typeID'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw HttpException('Unauthorized: Invalid or expired token.');
    } else if (response.statusCode == 404) {
      throw HttpException('User not found.');
    } else {
      throw HttpException('Failed to update profile. Please try again.');
    }
  } on SocketException {
    throw HttpException('No internet connection. Please check your network.');
  } on TimeoutException {
    throw HttpException('Server timeout. Please try again later.');
  } catch (e) {
    throw HttpException('An unexpected error occurred.');
  }
}

static Future<List<Map<String, String>>?> getInformationByUserType(String accessToken, String lang) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/Users/information_by_type'),
      headers: {
        'Content-Type': 'application/json',
        'lang': lang,
        'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List infoList = jsonData['information'];
      return infoList.map<Map<String, String>>((item) => {
        'text': item['text'],
        'image_path': item['image_path'],
      }).toList();
    } else if (response.statusCode == 401) {
      return null; // trigger token refresh
    } else {
      
      return null;
    }
  } catch (e) {
    return null;
  }
}



static Future<Map<String, dynamic>> getQuestionsByUserType(String accessToken, String lang) async {
  try {
    final response = await http
        .get(
          Uri.parse('$baseUrl/Users/questions_by_type'),
          headers: {
            'Content-Type': 'application/json',
            'lang': lang,
            'Authorization': 'Bearer $accessToken',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw HttpException('Unauthorized: Invalid or expired token.');
    } else if (response.statusCode == 404) {
      throw HttpException('User not found.');
    } else if (response.statusCode == 400) {
      throw HttpException('User does not have a typeID set.');
    } else {
      throw HttpException('Failed to fetch questions. Please try again.');
    }
  } on SocketException {
    throw HttpException('No internet connection. Please check your network.');
  } on TimeoutException {
    throw HttpException('Server timeout. Please try again later.');
  } catch (e) {
    throw HttpException('An unexpected error occurred while fetching questions.');
  }
}

static Future<Map<String, dynamic>> updateUserQuestion({
  required String accessToken,
  required String question,
}) async {
  try {
    final response = await http
        .put(
          Uri.parse('$baseUrl/Users/update_question'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'question': question}),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw HttpException('Unauthorized: Invalid or expired token.');
    } else if (response.statusCode == 404) {
      throw HttpException('User not found.');
    } else {
      throw HttpException('Failed to update question. Please try again.');
    }
  } on SocketException {
    throw HttpException('No internet connection. Please check your network.');
  } on TimeoutException {
    throw HttpException('Server timeout. Please try again later.');
  } catch (e) {
    throw HttpException('An unexpected error occurred while updating the question.');
  }
}

static Future<Map<String, dynamic>> getEncryptedUserInfo(String accessToken) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/Users/encrypted_info'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw HttpException('Failed to fetch encrypted info.');
    }
  } catch (e) {
    throw HttpException('An error occurred while getting encrypted info.');
  }
}

static Future<bool?> checkDeviceID(String accessToken) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/Users/check_deviceID'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['deviceID_is_null'];
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

static Future<void> disconnectGlass(String refreshToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/Users/logout_glasses'),
            headers: {
              'Content-Type': 'application/json',
              'refresh_token': refreshToken,
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Optionally, you could clear any local tokens here
        print("Logout successful");
      } else if (response.statusCode == 401) {
        throw HttpException('Invalid or expired refresh token.');
      } else {
        throw HttpException('Logout failed. Please try again.');
      }
    } on SocketException {
      throw HttpException('No internet connection. Please check your network and try again.');
    } on TimeoutException {
      throw HttpException('The server is taking too long to respond. Please try again later.');
    } catch (e) {
      throw HttpException('An unexpected error occurred during logout.');
    }
  }

static Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
  final response = await http.get(
    Uri.parse('$baseUrl/Users/profile'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw HttpException('Failed to fetch user profile');
  }
}

static Future<Map<String, dynamic>> getSuggestion({
  required String accessToken,
  required String promptText,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Users/get_suggestion'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'text': promptText}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw HttpException('Unauthorized: Invalid or expired token.');
    } else if (response.statusCode == 404) {
      throw HttpException('User not found.');
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw HttpException(error['detail'] ?? 'Bad request.');
    } else {
      throw HttpException('Failed to get suggestion. Please try again.');
    }
  } on SocketException {
    throw HttpException('No internet connection. Please check your network.');
  } on TimeoutException {
    throw HttpException('Server timeout. Please try again later.');
  } catch (e) {
    throw HttpException('An unexpected error occurred while getting suggestion.');
  }
}


}

