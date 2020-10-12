import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toast/toast.dart';
import 'package:pie_chart/pie_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckList Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'CheckList Beta 0.0'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController texto = TextEditingController();

  var listaTarefas = [];
  double percentual = 0.0;
  double diferencaPercentual = 100.0;
  Map<String, double> dataMap = {
    "Pendente": 100.0,
    "Concluído": 0.0,
  };

  void incluir(String tipo, int index, bool check) {
    if (tipo == 'Novo') {
      setState(() {
        listaTarefas.add(Tarefa(
          descricao: texto.text,
          data: DateTime.now(),
          check: false,
        ));
        percentual = (totalConcluida / listaTarefas.length) * 100;
        diferencaPercentual = 100 - percentual;
      });
    }
    if (tipo == 'Editar') {
      setState(() {
        if (check == true) {
          totalConcluida--;
        }
        listaTarefas[index] = Tarefa(
          descricao: texto.text,
          data: DateTime.now(),
          check: false,
        );
        percentual = (totalConcluida / listaTarefas.length) * 100;
        diferencaPercentual = 100 - percentual;
      });
    }
    dataMap['Concluído'] = percentual;
    dataMap['Pendente'] = diferencaPercentual;

    Navigator.of(context).pop();
    Toast.show('Tarefa Incluída', context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  int totalConcluida = 0;

  void _configurandoModalBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext criadorTarefa) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Card(
                elevation: 8.0,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: texto,
                      decoration: InputDecoration(
                        labelText: ' Tarefa',
                        hintText: ' Digite aqui sua nova tarefa',
                      ),
                    ),
                    RaisedButton(
                        child: Text('Incluir'),
                        onPressed: () {
                          if (texto.text != '') incluir('Novo', 0, true);
                          texto.clear();
                        }),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _configurandoModalBottomSheet(context);
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 1.0, right: 1.0),
            child: Card(
                elevation: 5.0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(' ${listaTarefas.length} Tarefas ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Text(' $totalConcluida Concluídas ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ]),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 200,
                            height: 100,
                            child: PieChart(
                              dataMap: dataMap,
                              chartType: ChartType.ring,
                            ),
                          )
                        ],
                      ),
                    ])),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: listaTarefas.length,
                  itemBuilder: (context, item) {
                    return Slidable(
                      key: UniqueKey(),
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                            caption: 'Editar',
                            color: Colors.grey.shade700,
                            icon: Icons.edit,
                            closeOnTap: false,
                            onTap: () {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext criadorTarefa) {
                                    return SingleChildScrollView(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: Card(
                                          elevation: 8.0,
                                          child: Column(
                                            children: <Widget>[
                                              TextField(
                                                controller: texto,
                                                decoration: InputDecoration(
                                                  labelText: ' Tarefa',
                                                  hintText:
                                                      ' Digite aqui sua nova tarefa',
                                                ),
                                              ),
                                              RaisedButton(
                                                  child: Text('Incluir'),
                                                  onPressed: () {
                                                    if (texto.text != '')
                                                      incluir(
                                                          'Editar',
                                                          item,
                                                          listaTarefas[item]
                                                              .check);
                                                    texto.clear();
                                                  }),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                              Toast.show('Atualizar Tarefa', context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.BOTTOM);
                            }),
                        IconSlideAction(
                            caption: 'Deletar',
                            color: Colors.red,
                            icon: Icons.delete,
                            closeOnTap: false,
                            onTap: () {
                              if (listaTarefas[item].check == true)
                                totalConcluida--;
                              listaTarefas.removeAt(item);
                              setState(() {
                                if (listaTarefas.length != 0) {
                                  percentual =
                                      (totalConcluida / listaTarefas.length) *
                                          100;
                                  diferencaPercentual = 100 - percentual;
                                } else {
                                  percentual = 0;
                                  diferencaPercentual = 100 - percentual;
                                }

                                dataMap['Concluído'] = percentual;
                                dataMap['Pendente'] = diferencaPercentual;
                              });
                              Toast.show('Tarefa Deletada', context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.BOTTOM);
                            })
                      ],
                      dismissal: SlidableDismissal(
                        child: SlidableDrawerDismissal(),
                        onDismissed: (_) {
                          if (listaTarefas[item].check == true)
                            totalConcluida--;
                          listaTarefas.removeAt(item);
                          setState(() {
                            if (listaTarefas.length != 0) {
                              percentual =
                                  (totalConcluida / listaTarefas.length) * 100;
                              diferencaPercentual = 100 - percentual;
                            } else {
                              percentual = 0;
                              diferencaPercentual = 100 - percentual;
                            }

                            dataMap['Concluído'] = percentual;
                            dataMap['Pendente'] = diferencaPercentual;
                          });
                        },
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 1.0, right: 1.0),
                        child: Card(
                          elevation: 8,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Transform.scale(
                                      scale: 1.25,
                                      child: Checkbox(
                                        value: listaTarefas[item].check,
                                        onChanged: (bool valendo) {
                                          setState(() {
                                            listaTarefas[item].check = valendo;
                                            if (listaTarefas[item].check == true)
                                              totalConcluida++;
                                            if (listaTarefas[item].check == false)
                                              totalConcluida--;
                                            percentual = (totalConcluida /
                                                    listaTarefas.length) *
                                                100;
                                            diferencaPercentual =
                                                100 - percentual;
                                            dataMap['Concluído'] = percentual;
                                            dataMap['Pendente'] =
                                                diferencaPercentual;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          'Item: ${listaTarefas[item].descricao}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          DateFormat('dd MM y')
                                              .format(listaTarefas[item].data),
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                    ])
                              ]),
                        ),
                      ),
                    );
                  })),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: FloatingActionButton(
              elevation: 8,
              foregroundColor: Colors.white,
              onPressed: () {
                _configurandoModalBottomSheet(context);
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class Tarefa {
  String descricao;
  DateTime data;
  bool check;

  Tarefa({
    @required this.descricao,
    @required this.data,
    @required this.check,
  });
}
