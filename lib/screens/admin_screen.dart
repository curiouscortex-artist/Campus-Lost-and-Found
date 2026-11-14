import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Management Console'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.assignment_turned_in), text: 'Claims'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Items'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Claims Tab
            state.claims.isEmpty
                ? const Center(
                    child: Text('No claims submitted yet.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.claims.length,
                    itemBuilder: (context, index) {
                      final claim = state.claims[index];
                      return Card(
                        child: ListTile(
                          title: Text('Item: ${claim.itemTitle}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Claimant: ${claim.claimantName}'),
                              Text('Proof: ${claim.proofDescription}'),
                              Text('QR Code: ${claim.qrCode}'),
                              Text(
                                'Status: ${claim.status.name.toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (claim.status == ClaimStatus.pending) ...[
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  tooltip: 'Approve Claim',
                                  onPressed: () {
                                    state.updateClaimStatus(
                                        claim.id, ClaimStatus.approved);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Claim approved!')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  tooltip: 'Reject Claim',
                                  onPressed: () {
                                    state.updateClaimStatus(
                                        claim.id, ClaimStatus.rejected);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Claim rejected!')),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // Items Tab
            state.items.isEmpty
                ? const Center(child: Text('No items posted.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(
                              'Category: ${item.category} | Location: ${item.location} | Status: ${item.status.name}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              state.deleteItem(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Item removed by admin.')),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

            // Users Tab
            state.users.isEmpty
                ? const Center(child: Text('No users registered.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(user.name[0].toUpperCase()),
                          ),
                          title: Text(user.name),
                          subtitle: Text(
                              '${user.email} | ${user.phone} | Role: ${user.role.name}'),
                          trailing: user.role == UserRole.admin
                              ? const Chip(label: Text('Admin'))
                              : IconButton(
                                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                                  onPressed: () {
                                    state.deleteUser(user.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('User deleted.')),
                                    );
                                  },
                                ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
