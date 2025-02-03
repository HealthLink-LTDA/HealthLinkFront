import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medical_app/models/user.dart';
import 'package:medical_app/providers/user_provider.dart';
import 'package:medical_app/providers/auth_provider.dart'; // Adicione esta linha

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _crmController = TextEditingController();
  int _selectedRole = 1;
  User? _editingMember;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers(); // Fetch team members when the screen loads
  }

  Future<void> _fetchTeamMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = Provider.of<UserProvider>(context, listen: false);
    final success = await provider.fetchTeamMembers();

    setState(() {
      _isLoading = false;
      if (!success) {
        _errorMessage =
            'Failed to load team members. Please check your network or API.';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _crmController.dispose();
    super.dispose();
  }

  void _showAddEditDialog(BuildContext context, [User? user]) {
    _editingMember = user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _passwordController.clear();
      _crmController.text = user.crm ?? '';
      _selectedRole = user.role;
    } else {
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _crmController.clear();
      _selectedRole = 1;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(user == null ? 'Adicionar membro' : 'Editar membro'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira seu nome completo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_editingMember == null)
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor insira um email';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Admin')),
                      DropdownMenuItem(value: 2, child: Text('Doutor')),
                      DropdownMenuItem(value: 3, child: Text('Enfermeira')),
                      DropdownMenuItem(value: 4, child: Text('Técnico')),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        _selectedRole = value!;
                        if (_selectedRole != 2) {
                          _crmController.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedRole == 2)
                    TextFormField(
                      controller: _crmController,
                      decoration: const InputDecoration(
                        labelText: 'CRM',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_selectedRole == 2 &&
                            (value == null || value.isEmpty)) {
                          return 'Por favor insira o CRM';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_editingMember == null &&
                          (value == null || value.isEmpty)) {
                        return 'Por favor insira uma senha';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final provider =
                      Provider.of<UserProvider>(context, listen: false);
                  if (_editingMember == null) {
                    provider.addTeamMember(
                      User(
                        id: DateTime.now().toString(),
                        name: _nameController.text,
                        email: _emailController.text,
                        role: _selectedRole,
                        password: _passwordController.text,
                        crm: _selectedRole == 2 ? _crmController.text : null,
                      ),
                    );
                  } else {
                    provider.updateTeamMember(
                      _editingMember!.id,
                      User(
                        id: _editingMember!.id,
                        name: _nameController.text,
                        email: _editingMember!.email,
                        role: _selectedRole,
                        password: _passwordController.text,
                        crm: _selectedRole == 2 ? _crmController.text : null,
                      ),
                    );
                  }
                  provider.fetchTeamMembers();
                  Navigator.pop(context);
                }
              },
              child: Text(_editingMember == null ? 'Adicionar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, User member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Você tem certeza que quer deletar ${member.name} da sua equipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider =
                  Provider.of<UserProvider>(context, listen: false);
              provider.deleteTeamMember(member.id);
              provider.fetchTeamMembers();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Deletar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String getRoleText(int role) {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Doutor';
      case 3:
        return 'Enfermeira';
      case 4:
        return 'Técnico';
      default:
        return 'Desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context); // Verifica o provider de Auth
    final isAdmin = authProvider.userRole == 1; // Verifica se o usuário é admin

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipe Médica'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchTeamMembers,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Consumer<UserProvider>(builder: (context, provider, _) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.team.length,
                    itemBuilder: (context, index) {
                      final member = provider.team[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(getRoleText(member.role)),
                              Text(member.email),
                              if (member.crm != null)
                                Text('CRM: ${member.crm}'),
                              const SizedBox(height: 8),
                              if (isAdmin) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _showAddEditDialog(context, member),
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () => _showDeleteConfirmation(
                                          context, member),
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
