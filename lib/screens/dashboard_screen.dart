import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import '../services/validators.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedType = 'All';

  final List<String> categories = [
    'All',
    'Electronics',
    'Books',
    'Personal Items',
    'Clothing',
    'IDs & Cards',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final user = state.currentUser;
    final isCompact = MediaQuery.sizeOf(context).width < 560;

    var filteredItems = state.items.where((item) {
      bool matchesSearch = item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesCategory =
          selectedCategory == 'All' || item.category == selectedCategory;
      bool matchesType = selectedType == 'All' ||
          (selectedType == 'Lost' && item.type == ItemType.lost) ||
          (selectedType == 'Found' && item.type == ItemType.found);

      return matchesSearch && matchesCategory && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Lost & Found'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (value) {
              switch (value) {
                case 'scan':
                  Navigator.pushNamed(context, '/qr_scanner');
                  break;
                case 'admin':
                  Navigator.pushNamed(context, '/admin');
                  break;
                case 'regex':
                  Navigator.pushNamed(context, '/regex_defense');
                  break;
                case 'logout':
                  state.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'scan',
                child: ListTile(
                  leading: Icon(Icons.qr_code_scanner),
                  title: Text('Verify claim'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (state.isAdmin)
                const PopupMenuItem(
                  value: 'admin',
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings),
                    title: Text('Admin panel'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'regex',
                child: ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Validation info'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log out'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // User banner
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text(user?.name[0].toUpperCase() ?? 'U'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _userIdentity(user)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Post Item'),
                        onPressed: () => _showItemDialog(context),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        child: Text(user?.name[0].toUpperCase() ?? 'U'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _userIdentity(user)),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Post Item'),
                        onPressed: () => _showItemDialog(context),
                      ),
                    ],
                  ),
          ),

          // Filters & Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search items by title, description or location...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedCategory = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        items: ['All', 'Lost', 'Found']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedType = val);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Items List View
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No items found match your search criteria.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isOwner = item.userId == user?.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Chip(
                                    label: Text(
                                      item.type.name.toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: item.type == ItemType.lost
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                  Chip(
                                    label: Text(item.category),
                                  ),
                                  Chip(
                                    label: Text(item.status.name.toUpperCase()),
                                    backgroundColor: item.status == ItemStatus.open
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade300,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(item.description),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  Text(item.location),
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey),
                                  Text(
                                    '${item.date}  |  Est. \$${item.estimatedValue}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Posted by: ${item.userName}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              const Divider(),
                              Wrap(
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.qr_code),
                                    tooltip: 'Show QR Verification Code',
                                    onPressed: () => _showQrDialog(context, item),
                                  ),
                                  if (isOwner || state.isAdmin) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () =>
                                          _showItemDialog(context, item: item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        state.deleteItem(item.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text('Item deleted.')),
                                        );
                                      },
                                    ),
                                  ],
                                  if (!isOwner && item.status == ItemStatus.open)
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.assignment_turned_in),
                                      label: const Text('Claim Item'),
                                      onPressed: () =>
                                          _showClaimDialog(context, item),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _userIdentity(User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${user?.name ?? "User"}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '${user?.email ?? ""} (${user?.role.name.toUpperCase() ?? "USER"})',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showQrDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verification QR - ${item.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: QrImageView(
                data: item.qrVerificationCode,
                version: QrVersions.auto,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              'Code: ${item.qrVerificationCode}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan this QR code during item claim handover to verify authenticity.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  void _showClaimDialog(BuildContext context, Item item) {
    final proofController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Claim Request: ${item.title}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Provide unique proof of ownership (e.g., serial number, specific marks, contents inside).',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: proofController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Proof Description',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().length < 5 ? 'Provide detailed proof' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final state = Provider.of<AppState>(context, listen: false);
                bool ok = state.submitClaim(item, proofController.text.trim());
                Navigator.pop(context);
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Claim request submitted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have already submitted a claim for this item.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            child: const Text('Submit Claim'),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(BuildContext context, {Item? item}) {
    final isEdit = item != null;
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController(text: item?.title ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final locationController = TextEditingController(text: item?.location ?? '');
    final dateController = TextEditingController(
      text: item?.date ?? DateTime.now().toString().split(' ')[0],
    );
    final priceController = TextEditingController(text: item?.estimatedValue ?? '10');

    String category = item?.category ?? 'Electronics';
    ItemType type = item?.type ?? ItemType.lost;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Item' : 'Post New Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Item Title (5-60 chars)',
                      border: OutlineInputBorder(),
                      helperText: 'Regex: ^.{5,60}\$',
                    ),
                    validator: Validators.validateItemTitle,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Description required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Electronics',
                      'Books',
                      'Personal Items',
                      'Clothing',
                      'IDs & Cards',
                      'Other'
                    ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setDialogState(() => category = val!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location Found/Lost',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Location required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                      helperText: 'Regex: ^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01])\$',
                    ),
                    validator: Validators.validateDate,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Value / Price (\$) (Numeric)',
                      border: OutlineInputBorder(),
                      helperText: 'Regex: ^\\d+(\\.\\d{1,2})?\$',
                    ),
                    validator: Validators.validateNumeric,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ItemType>(
                    segments: const [
                      ButtonSegment<ItemType>(
                        value: ItemType.lost,
                        label: Text('Lost'),
                      ),
                      ButtonSegment<ItemType>(
                        value: ItemType.found,
                        label: Text('Found'),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (newSelection) {
                      setDialogState(() => type = newSelection.first);
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
                if (formKey.currentState!.validate()) {
                  final state = Provider.of<AppState>(context, listen: false);
                  if (isEdit) {
                    item.status = item.status;
                    var updated = Item(
                      id: item.id,
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      category: category,
                      location: locationController.text.trim(),
                      date: dateController.text.trim(),
                      estimatedValue: priceController.text.trim(),
                      type: type,
                      status: item.status,
                      userId: item.userId,
                      userName: item.userName,
                      qrVerificationCode: item.qrVerificationCode,
                    );
                    state.updateItem(updated);
                  } else {
                    state.addItem(
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      category: category,
                      location: locationController.text.trim(),
                      date: dateController.text.trim(),
                      estimatedValue: priceController.text.trim(),
                      type: type,
                    );
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Item updated!' : 'Item posted!'),
                    ),
                  );
                }
              },
              child: Text(isEdit ? 'Save Changes' : 'Post Item'),
            ),
          ],
        ),
      ),
    );
  }
}
