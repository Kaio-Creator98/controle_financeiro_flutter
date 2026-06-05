import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewmodels/dashboard_viewmodel.dart';

class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final total = vm.totalIncome + vm.totalExpense;
    final expensePercent = total == 0 ? 0.0 : vm.totalExpense / total;
    final incomePercent = total == 0 ? 0.0 : vm.totalIncome / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados e Análise'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo do orçamento',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Receitas: ${(incomePercent * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: incomePercent,
                    minHeight: 10,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 18),
                  Text('Despesas: ${(expensePercent * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: expensePercent,
                    minHeight: 10,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 18),
                  Text('Saldo: ${currencyFormat.format(vm.balance)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Lista completa de movimentações',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (vm.transactions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('Nenhuma movimentação cadastrada.'),
                ),
              ),
            )
          else
            ...vm.transactions.map(
              (transaction) => Card(
                child: ListTile(
                  leading: Icon(
                    transaction.isIncome
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: transaction.isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(transaction.title),
                  subtitle: Text(
                    '${transaction.isIncome ? 'Receita' : 'Despesa'} • ${transaction.date}',
                  ),
                  trailing: Text(
                    currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      color: transaction.isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
