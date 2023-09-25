import 'dart:convert';

import 'package:prova_flash/data/http/exceptions.dart';
import 'package:prova_flash/data/http/http_client.dart';
import 'package:prova_flash/data/models/quote_model.dart';

abstract class IQuoteRepository {
  Future<List<QuoteModel>> getQuotes(referenceDate);
}

class ProdutoRepository implements IQuoteRepository {
  final IHttpClient client;

  ProdutoRepository({required this.client});

  @override
  Future<List<QuoteModel>> getQuotes(referenceDate) async {
    final response = await client.get(
      url: 'https://dummyjson.com/products',
    );

    if (response.statusCode == 200) {
      final List<QuoteModel> quotes = [];

      final body = jsonDecode(response.body);

      body['products'].map((item) {
        final QuoteModel quote = QuoteModel.fromMap(item);
        quotes.add(quote);
      }).toList();

      return quotes;
    } else if (response.statusCode == 404) {
      throw NotFoundException('A url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar a cotação solicitada');
    }
  }
}
