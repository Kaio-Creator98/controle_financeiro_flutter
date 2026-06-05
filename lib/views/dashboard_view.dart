import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final dashboardViewModel = context.watch<DashboardViewModel>();
    final user = authViewModel.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuário não autenticado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user.name}'),
        actions: [
          IconButton(
            tooltip: 'Análise',
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.pushNamed(context, '/analysis');
            },
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () {
              authViewModel.logout();
              dashboardViewModel.clear();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => dashboardViewModel.loadTransactions(user.id!),
        child: dashboardViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryCard(
                    balance: dashboardViewModel.balance,
                    totalIncome: dashboardViewModel.totalIncome,
                    totalExpense: dashboardViewModel.totalExpense,
                    currencyFormat: _currencyFormat,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Transações',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (dashboardViewModel.transactions.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text('Nenhuma transação cadastrada.'),
                        ),
                      ),
                    )
                  else
                    ...dashboardViewModel.transactions.map(
                      (transaction) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.isIncome
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              transaction.isIncome
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: transaction.isIncome
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(transaction.title),
                          subtitle: Text(
                            '${transaction.isIncome ? 'Receita' : 'Despesa'} • ${transaction.date}',
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                _currencyFormat.format(transaction.amount),
                                style: TextStyle(
                                  color: transaction.isIncome
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showTransactionForm(
                                    context,
                                    userId: user.id!,
                                    transaction: transaction,
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Excluir',
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _confirmDelete(
                                    context,
                                    transaction: transaction,
                                    userId: user.id!,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTransactionForm(context, userId: user.id!);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context, {
    required TransactionModel transaction,
    required int userId,
  }) async {
    final dashboardViewModel = context.read<DashboardViewModel>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir transação'),
          content: Text('Deseja excluir "${transaction.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true && transaction.id != null) {
      await dashboardViewModel.deleteTransaction(
        id: transaction.id!,
        userId: userId,
      );
    }
  }

  void _showTransactionForm(
    BuildContext context, {
    required int userId,
    TransactionModel? transaction,
  }) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: transaction?.title ?? '');
    final amountController = TextEditingController(
      text: transaction == null ? '' : transaction.amount.toStringAsFixed(2),
    );

    DateTime selectedDate = transaction == null
        ? DateTime.now()
        : DateTime.tryParse(transaction.date) ?? DateTime.now();

    bool isIncome = transaction?.isIncome ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction == null
                            ? 'Nova transação'
                            : 'Editar transação',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o título.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o valor.';
                          }

                          final normalizedValue = value.replaceAll(',', '.');
                          final amount = double.tryParse(normalizedValue);

                          if (amount == null || amount <= 0) {
                            return 'Informe um valor numérico válido.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Data'),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            setModalState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(isIncome ? 'Tipo: Entrada' : 'Tipo: Saída'),
                        subtitle: const Text('Use o botão para alternar.'),
                        value: isIncome,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        onChanged: (value) {
                          setModalState(() {
                            isIncome = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final dashboardViewModel =
                                context.read<DashboardViewModel>();

                            final amount = double.parse(
                              amountController.text.replaceAll(',', '.'),
                            );

                            final newTransaction = TransactionModel(
                              id: transaction?.id,
                              userId: userId,
                              title: titleController.text.trim(),
                              amount: amount,
                              date: DateFormat('yyyy-MM-dd').format(selectedDate),
                              isIncome: isIncome,
                            );

                            if (transaction == null) {
                              await dashboardViewModel.addTransaction(
                                newTransaction,
                              );
                            } else {
                              await dashboardViewModel.updateTransaction(
                                newTransaction,
                              );
                            }

                            if (context.mounted) {
                              Navigator.pop(bottomSheetContext);
                            }
                          },
                          child: Text(
                            transaction == null ? 'Adicionar' : 'Salvar alterações',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final NumberFormat currencyFormat;

  const _SummaryCard({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final balanceColor = balance >= 0 ? Colors.deepPurple : Colors.red;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              'Saldo Atual',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(balance),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: balanceColor,
              ),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ValueInfo(
                  title: 'Receitas',
                  value: currencyFormat.format(totalIncome),
                  color: Colors.green,
                ),
                _ValueInfo(
                  title: 'Despesas',
                  value: currencyFormat.format(totalExpense),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ValueInfo({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
