import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medical_app/models/user.dart';
import 'package:medical_app/providers/data_provider.dart';

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
  String _selectedRole = 'doctor';
  User? _editingMember;

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
      _selectedRole = 'doctor';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? 'Add Team Member' : 'Edit Team Member'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter full name';
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
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                      DropdownMenuItem(value: 'nurse', child: Text('Nurse')),
                      DropdownMenuItem(
                          value: 'technician', child: Text('Technician')),
                      DropdownMenuItem(
                          value: 'assistant', child: Text('Nursing Assistant')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                        if (_selectedRole != 'doctor') {
                          _crmController.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedRole == 'doctor')
                    TextFormField(
                      controller: _crmController,
                      decoration: const InputDecoration(
                        labelText: 'CRM',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_selectedRole == 'doctor' &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter CRM';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_editingMember == null &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter password';
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_editingMember == null) {
                    final user = User(
                      id: DateTime.now().toString(),
                      name: _nameController.text,
                      email: _emailController.text,
                      role: _selectedRole,
                      crm: _selectedRole == 'doctor'
                          ? _crmController.text
                          : null,
                    );
                    context.read<DataProvider>().addTeamMember(user);
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Edit'),
                        content: Text(
                            'Do you want to save the changes for ${_nameController.text}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final updatedUser = User(
                                id: _editingMember!.id,
                                name: _nameController.text,
                                email: _editingMember!.email,
                                role: _selectedRole,
                                crm: _selectedRole == 'doctor'
                                    ? _crmController.text
                                    : null,
                              );

                              context.read<DataProvider>().updateTeamMember(
                                    _editingMember!.id,
                                    updatedUser,
                                  );

                              Navigator.pop(
                                  context); // Fecha o diálogo de confirmação
                              Navigator.pop(
                                  context); // Fecha o diálogo de edição
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: Text(_editingMember == null ? 'Add' : 'Save'),
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
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to remove ${member.name} from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().deleteTeamMember(member.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleUpdate(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Update'),
          content: Text(
              'Are you sure you want to update ${_nameController.text}\'s information?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedUser = User(
                  id: _editingMember!.id,
                  name: _nameController.text,
                  email: _editingMember!.email,
                  role: _selectedRole,
                  crm: _selectedRole == 'doctor' ? _crmController.text : null,
                );

                context.read<DataProvider>().updateTeamMember(
                      _editingMember!.id,
                      updatedUser,
                    );

                Navigator.pop(context); // Fecha o diálogo de confirmação
                Navigator.pop(context); // Fecha o diálogo de edição
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Update'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Team'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
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
                      Text(
                        member.role[0].toUpperCase() + member.role.substring(1),
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(member.email),
                      if (member.role == 'doctor' && member.crm != null)
                        Text('CRM: ${member.crm}'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                _showAddEditDialog(context, member),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                _showDeleteConfirmation(context, member),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}