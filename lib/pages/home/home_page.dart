import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prova_flash/data/http/http_client.dart';
import 'package:prova_flash/data/models/quote_model.dart';
import 'package:prova_flash/data/repositories/quote_repository.dart';
import 'package:pdf/widgets.dart' as pw;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  TextEditingController dateInput = TextEditingController();
  List<QuoteModel> quoteList = List.empty();
  DateTime originalDate = DateTime.now().subtract(const Duration(hours: 3));
  late QuoteModel lastRemoved;
  late int lastRemovedPos;

  @override
  void initState() {
    isLoading = false;
    quoteList = [];
    originalDate = DateTime.now().subtract(const Duration(hours: 3));
    dateInput.text = DateFormat('dd/MM/yyyy')
        .format(DateTime.now().subtract(const Duration(hours: 3)));
    super.initState();
  }

  Future saveToPDF() async {
    final pdf = pw.Document();
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/cotacaoDolar';
    await Directory(directoryPath)
        .create(recursive: true); // the error because of this line
    String filePath =
        '$directoryPath/Relatório cotações ${DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(const Duration(hours: 3)))}.pdf';

    pdf.addPage(
      pw.Page(
        build: (pw.Context pdfContext) {
          return pw.Column(
            children: quoteList
                .map((item) => pw.Text(
                    'Dólar cotado em: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(item.dataHoraCotacao))}\nValor de compra: \$${item.cotacaoCompra.toStringAsFixed(2)} \nValor de venda: \$${item.cotacaoVenda.toStringAsFixed(2)}'))
                .toList(),
          );
        },
      ),
    );

    final file = File(filePath);
    file.writeAsBytesSync(await pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: const Text(
            'Cotação Dólar',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(15),
                height: MediaQuery.of(context).size.width / 3,
                child: Center(
                  child: TextField(
                      controller: dateInput,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          iconColor: Color(0xFF0D47A1),
                          labelText: "Data de cotação",
                          labelStyle: TextStyle(color: Color(0xFF0D47A1)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF0D47A1)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateUtils.dateOnly(DateTime.now()
                              .subtract(const Duration(hours: 3))),
                          firstDate: DateUtils.dateOnly(DateTime(1950)),
                          lastDate: DateUtils.dateOnly(DateTime.now()
                              .subtract(const Duration(hours: 3))),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('dd/MM/yyyy').format(pickedDate);

                          setState(() {
                            originalDate = pickedDate;
                            dateInput.text = formattedDate;
                          });
                        }
                      }),
                )),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blue.shade900)),
                onPressed: () async {
                  List<QuoteModel> quoteListCopy = quoteList;

                  List<QuoteModel> quotedDate = await QuoteRepository(
                          client: HttpClient())
                      .getQuotes(DateFormat('MM-dd-yyyy').format(originalDate));

                  if (quotedDate.isNotEmpty &&
                      quoteListCopy.any((quoteCopy) =>
                          quoteCopy.dataHoraCotacao ==
                          quotedDate[0].dataHoraCotacao)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cotação já foi realizada nessa data'),
                      ),
                    );
                  } else if (quotedDate.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Não foram encontradas cotações na data selecionada'),
                      ),
                    );
                  } else {
                    quoteListCopy.add(quotedDate[0]);
                  }

                  setState(() {
                    quoteList = quoteListCopy;
                  });
                },
                child: const Text('Confirmar')),
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10.0),
                  itemCount: quoteList.length,
                  itemBuilder: buildItem),
            ),
            quoteList.any((quoteCopy) => quoteCopy.selecionado == true)
                ? ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue.shade900)),
                    onPressed: () => saveToPDF(),
                    child: const Icon(Icons.picture_as_pdf),
                  )
                : Container()
          ],
        ));
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(
            'Dólar cotado em: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(quoteList[index].dataHoraCotacao))}'),
        dense: true,
        subtitle: Text(
            'Valor de compra: \$${quoteList[index].cotacaoCompra.toStringAsFixed(2)} \nValor de venda: \$${quoteList[index].cotacaoVenda.toStringAsFixed(2)}'),
        value: quoteList[index].selecionado,
        secondary: CircleAvatar(
          backgroundColor: quoteList[index].selecionado
              ? Colors.amber
              : Colors.blue.shade900,
          child: const Icon(Icons.attach_money),
        ),
        onChanged: (checked) {
          setState(() {
            quoteList[index].selecionado = checked!;
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          lastRemoved = quoteList[index];
          lastRemovedPos = index;
          quoteList.removeAt(index);

          final snack = SnackBar(
            content: Text(
                "Cotação de \"${DateFormat('dd/MM/yyyy').format(DateTime.parse(lastRemoved.dataHoraCotacao))}\" removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    quoteList.insert(lastRemovedPos, lastRemoved);
                  });
                }),
            duration: const Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }
}
