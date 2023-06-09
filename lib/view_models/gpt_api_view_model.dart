import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../database/api_key_storage_helper.dart';
import '../providers/export_providers.dart';

class GPTAPIViewModel extends ChangeNotifier {
  Future<void> fetchGPTResponse(
    BuildContext context,
    APIKeyStorageHelper apiStorage,
    String input,
  ) async {
    /*
     
    Initialize all the providers we need first to get needed fields or to update fields

    - settingsProvider: to get the api key and temperature
    - isLoadingProvider: to set the loading icon to true
    - chatHistoryProvider: to add the user prompt and the gpt response to the chat history for conversational context
    */

    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    final isLoadingProvider =
        Provider.of<LoadingIconGPTProvider>(context, listen: false);

    final chatHistoryProvider =
        Provider.of<ChatHistoryProvider>(context, listen: false);

    //since we are fetching request - we will set the loading icon to true so we can display it in answer text box temporarily
    isLoadingProvider.setIsLoading(true);

    //add the user prompt to the chat history
    chatHistoryProvider.addUserPrompt(input);

    //only supporting gpt-3.5-turbo for now
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${(await apiStorage.getGPTAPIKey()) ?? ""}', //api key decrypted only once its needed for request
    };

    Map<String, dynamic> requestBody = {
      "model": "gpt-3.5-turbo",
      "messages": chatHistoryProvider.chatHistory,
      "temperature": settingsProvider.gptTemp,
      "max_tokens": 200,
    };

    try {
      //this is where we send the request to the gpt api
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(requestBody),
      );

      //set the loading icon to false since we are done fetching the response
      isLoadingProvider.setIsLoading(false);

      debugPrint(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = json.decode(response.body);
        String answer = responseJson['choices'][0]['message']
            ['content']; //extract the message from the response

        //add the gpt response to the history to keep conversational context
        chatHistoryProvider.addGPTResponse(answer);
      } else {
        //uncomment 'responeJson' below if you want to get the exact error code retrieved from API otherwise its useless
        // Map<String, dynamic> responseJson = json.decode(response.body);
        String errorSummary =
            "Your GPT API key is invalid. Please update your GPT API key and CONFIRM it in the settings section!";
        chatHistoryProvider.addGPTResponse(errorSummary);
      }
    } catch (e) {
      debugPrint("catch error");
      debugPrint('Request failed with error: $e');
    } finally {
      //notify the listeners to update the ui to remove the loading icon and display the answer regardless of success or failure
      notifyListeners();
    }
  } //get response from chatgpt future function
}
