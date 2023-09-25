import 'package:flutter/material.dart';
import 'package:prova_flash/data/http/exceptions.dart';
import 'package:prova_flash/data/models/quote_model.dart';
import 'package:prova_flash/data/repositories/quote_repository.dart';

class QuoteStore {
  final IQuoteRepository repository;

  // Variável reativa para o loading
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  // Variável reativa para o state
  final ValueNotifier<List<QuoteModel>> state =
      ValueNotifier<List<QuoteModel>>([]);

  // Variável reativa para o erro
  final ValueNotifier<String> erro = ValueNotifier<String>('');

  QuoteStore({required this.repository});

  Future getDailyQuotes(String referenceDate) async {
    isLoading.value = true;

    try {
      final result = await repository.getQuotes(referenceDate);
      state.value = result;
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } catch (e) {
      erro.value = e.toString();
    }

    isLoading.value = false;
  }
}
