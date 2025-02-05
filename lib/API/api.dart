// ignore_for_file: avoid_print, unused_element, prefer_const_constructors

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Constants/Variable.dart';
import '../Module/News.dart';
import '../Module/StockLoserGainer.dart';

class API {
  // Call market news from API
  Future<List<Map<String, dynamic>>> getMarketNews(String category) async {
    try {
      var url =
          'https://finnhub.io/api/v1/news?category=$category&token=$apiFinnhub';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        final List<Map<String, dynamic>> items = [];

        for (var item in jsonData) {
          items.add({
            "headline": item["headline"],
            "image": item["image"],
            "source": item["source"],
            "summary": item["summary"],
            "url": item["url"],
          });
        }

        print(items);
        return items;
      } else {
        // Handle non-200 response status codes
        print(
            'Failed to fetch market news. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('An error occurred: $e');
      return [];
    }
  }

  //Search Stocks
  Future<List<Map<String, dynamic>>> searchStocks(String query) async {
    final url =
        'https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=$query&apikey=$apiAlpha';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final searchResults = json.decode(response.body)['result'];
      return List<Map<String, dynamic>>.from(searchResults);
    } else {
      print("API request error: ${response.statusCode}");
      return [];
    }
  }

  // Get stock profile
  Future<Map<String, dynamic>> getStockProfile(String symbol) async {
    final url =
        'https://finnhub.io/api/v1/stock/profile2?symbol=$symbol&token=$apiFinnhub';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final stockProfile = json.decode(response.body);
      return Map<String, dynamic>.from(stockProfile);
    } else {
      print("API request error: ${response.statusCode}");
      return {};
    }
  }

  Future<Map<String, dynamic>> getStockProfileFromAlpha(String symbol) async {
    final url =
        'https://www.alphavantage.co/query?function=OVERVIEW&symbol=$symbol&apikey=$apiAlpha';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final stockProfile = json.decode(response.body);
      return Map<String, dynamic>.from(stockProfile);
    } else {
      print("API request error: ${response.statusCode}");
      return {};
    }
  }

  //Get Quote data od stack
  Future<Map<String, dynamic>> fetchStockQuoteData(String symbol) async {
    final url =
        'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiFinnhub';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print("API request error: ${response.statusCode}");
        return {};
      }
    } catch (error) {
      print("Error fetching stock quote data: $error");
      return {};
    }
  }

  // Get Recommendation Data
  Future<List<dynamic>> getRecommendationData(String symbol) async {
    final url =
        'https://finnhub.io/api/v1/stock/recommendation?symbol=$symbol&token=$apiFinnhub';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        return data; // Returning a List<dynamic>
      } else {
        print("API request error: ${response.statusCode}");
        return []; // Returning an empty list as default
      }
    } catch (error) {
      print("Error fetching stock recommendation data: $error");
      return []; // Returning an empty list as default
    }
  }

  // Get data of market stutus
  Future<List<Map<String, dynamic>>> getMarketStatus() async {
    const url =
        'https://www.alphavantage.co/query?function=MARKET_STATUS&apikey=$apiAlpha';

    try {
      final response = await http.get(Uri.parse(url));
      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['markets'];
        // print('DATA: $data');
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("API request error: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching market status data: $error");
      return [];
    }
  }

  // Get news for specific stocks
  Future<List<News>> fetchStockNews({required String ticker}) async {
    final DateTime currentDate = DateTime.now();
    final DateTime fromDate = currentDate.subtract(Duration(days: 10));
    final String fromDateString = fromDate.toIso8601String().substring(0, 10);
    final String toDateString = currentDate.toIso8601String().substring(0, 10);

    final url =
        'https://finnhub.io/api/v1/company-news?symbol=$ticker&from=$fromDateString&to=$toDateString&token=$apiFinnhub';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<News> news = [];

        for (var item in jsonData) {
          news.add(News.fromJson(item));
        }
        return news;
      } else {
        print("API request error: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching stock news data: $error");
      return [];
    }
  }

  Future<StockData> fetchData() async {
    final response = await http.get(
        Uri.parse(
            'https://www.alphavantage.co/query?function=TOP_GAINERS_LOSERS&apikey=$apiAlpha'),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return StockData.fromJson(jsonData);
    } else {
      throw Exception('Failed to load data');
    }
  }

  //Get Stock inside 
  Future<StockData> getStockInside({required String ticker}) async {
    final response = await http.get(Uri.parse(
        'https://www.alphavantage.co/query?function=OVERVIEW&symbol=$ticker&apikey=$apiAlpha'));
        if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return StockData.fromJson(jsonData);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
