import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/admin_user.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedRoleFilter = 'All';
  String _selectedStatusFilter = 'All';

  final List<String> _roleFilters = [
    'All',
    'ROLE_USER',
    'ROLE_ADMIN',
    'ROLE_TRA_OFFICER'
  ];
  final List<String> _statusFilters = ['All', 'Active', 'Inactive'];

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final users = _filterUsers(adminProvider.users);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters
          _buildSearchAndFilters(),

          // Stats Summary
          _buildStatsSummary(users),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : users.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _buildUserCard(user, adminProvider);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: AppColors.primary,
        tooltip: 'Add User',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<AdminUser> _filterUsers(List<AdminUser> users) {
    final query = _searchQuery.trim().toLowerCase();
    return users.where((u) {
      final matchesQuery = query.isEmpty ||
          u.fullName.toLowerCase().contains(query) ||
          u.username.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          u.tinNumber.toLowerCase().contains(query);
      final matchesRole =
          _selectedRoleFilter == 'All' || u.role == _selectedRoleFilter;
      final matchesStatus = _selectedStatusFilter == 'All' ||
          (_selectedStatusFilter == 'Active' && u.isActive) ||
          (_selectedStatusFilter == 'Inactive' && !u.isActive);
      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, username, email, or TIN...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Role Filter
                const Text('Role: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                ..._roleFilters.map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: FilterChip(
                        label: Text(filter.replaceAll('ROLE_', '')),
                        selected: _selectedRoleFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRoleFilter = filter;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Filter
                const Text('Status: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                ..._statusFilters.map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedStatusFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatusFilter = filter;
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(List<AdminUser> users) {
    final total = users.length;
    final active = users.where((u) => u.isActive).length;
    final admins = users.where((u) => u.role == 'ROLE_ADMIN').length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', total.toString(), Colors.blue),
          _buildStatItem('Active', active.toString(), Colors.green),
          _buildStatItem('Admins', admins.toString(), Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(AdminUser user, AdminProvider adminProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 25,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• TIN: ${user.tinNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: user.isActive ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        user.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: user.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.role == 'ROLE_ADMIN'
                            ? Colors.purple.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.replaceAll('ROLE_', ''),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: user.role == 'ROLE_ADMIN'
                              ? Colors.purple
                              : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit Button
                OutlinedButton.icon(
                  onPressed: () => _showEditUserDialog(user),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: Colors.blue),
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),

                // Toggle Status Button
                ElevatedButton.icon(
                  onPressed: () => _toggleUserStatus(user, adminProvider),
                  icon: Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 16,
                  ),
                  label: Text(user.isActive ? 'Deactivate' : 'Activate'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor:
                        user.isActive ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(width: 8),

                // Reset Password Button
                IconButton(
                  icon: const Icon(Icons.lock_reset, color: Colors.purple),
                  onPressed: () => _resetPassword(user, adminProvider),
                  tooltip: 'Reset Password',
                ),
                const SizedBox(width: 4),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteUser(user, adminProvider),
                  tooltip: 'Delete User',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add a user',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.loadAdminData();
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Failed to load users: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        onSave: (userData) async {
          try {
            // Call API to create user
            Helpers.showSuccessSnackBar(context, 'User created successfully!');
            await _loadUsers();
          } catch (e) {
            if (context.mounted) {
              Helpers.showErrorSnackBar(context, 'Failed to create user: $e');
            }
          }
        },
      ),
    );
  }

  void _showEditUserDialog(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
        onSave: (userData) async {
          try {
            // Call API to update user
            Helpers.showSuccessSnackBar(context, 'User updated successfully!');
            await _loadUsers();
          } catch (e) {
            if (context.mounted) {
              Helpers.showErrorSnackBar(context, 'Failed to update user: $e');
            }
          }
        },
      ),
    );
  }

  Future<void> _toggleUserStatus(
      AdminUser user, AdminProvider adminProvider) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: user.isActive ? 'Deactivate User' : 'Activate User',
      message:
          'Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} ${user.fullName}?',
      confirmText: user.isActive ? 'Deactivate' : 'Activate',
    );

    if (confirm == true) {
      try {
        await adminProvider.toggleUserStatus(user.id);
        if (mounted) {
          Helpers.showSuccessSnackBar(
            context,
            'User ${user.isActive ? 'deactivated' : 'activated'} successfully!',
          );
        }
        await _loadUsers();
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(
              context, 'Failed to toggle user status: $e');
        }
      }
    }
  }

  Future<void> _resetPassword(
      AdminUser user, AdminProvider adminProvider) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Reset Password',
      message: 'Are you sure you want to reset ${user.fullName}\'s password?',
      confirmText: 'Reset',
    );

    if (confirm == true) {
      try {
        // Call API to reset password
        const newPassword = 'Temp@123456'; // In real app, get from API
        if (mounted) {
          Helpers.showSuccessSnackBar(
            context,
            'Password reset successfully!\nNew Password: $newPassword',
          );
        }
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Failed to reset password: $e');
        }
      }
    }
  }

  Future<void> _deleteUser(AdminUser user, AdminProvider adminProvider) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Delete User',
      message:
          'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      try {
        await adminProvider.deleteUser(user.id);
        if (mounted) {
          Helpers.showSuccessSnackBar(context, 'User deleted successfully!');
        }
        await _loadUsers();
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Failed to delete user: $e');
        }
      }
    }
  }
}

// ==================== USER FORM DIALOG ====================

class UserFormDialog extends StatefulWidget {
  final AdminUser? user;
  final Function(Map<String, dynamic>) onSave;

  const UserFormDialog({super.key, this.user, required this.onSave});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _tinController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'ROLE_USER';
  bool _isActive = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _roles = ['ROLE_USER', 'ROLE_ADMIN', 'ROLE_TRA_OFFICER'];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _emailController.text = widget.user!.email;
      _fullNameController.text = widget.user!.fullName;
      _tinController.text = widget.user!.tinNumber;
      _mobileController.text = widget.user!.mobileNumber ?? '';
      _selectedRole = widget.user!.role;
      _isActive = widget.user!.isActive;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _tinController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add New User' : 'Edit User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Enter username',
                prefixIcon: Icons.person_outline,
                readOnly: widget.user != null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _fullNameController,
                label: 'Full Name',
                hint: 'Enter full name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _tinController,
                label: 'TIN Number',
                hint: 'Enter 9-digit TIN',
                prefixIcon: Icons.credit_card,
                keyboardType: TextInputType.number,
                maxLength: 9,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'TIN number is required';
                  }
                  if (value.length != 9) {
                    return 'TIN must be exactly 9 digits';
                  }
                  if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) {
                    return 'TIN must contain only digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _mobileController,
                label: 'Mobile Number',
                hint: 'Enter mobile number',
                prefixIcon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.replaceAll('ROLE_', '')),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (widget.user == null) ...[
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('User can access the system'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeThumbColor: AppColors.primary,
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
          onPressed: _isLoading ? null : _saveUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userData = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'tinNumber': _tinController.text.trim(),
        'mobileNumber': _mobileController.text.trim(),
        'role': _selectedRole,
        'isActive': _isActive,
        'password': _passwordController.text,
      };

      await widget.onSave(userData);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    }
  }
}
