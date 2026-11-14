import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import 'validators.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];
  List<Item> _items = [];
  List<Claim> _claims = [];

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  List<Item> get items => _items;
  List<Claim> get claims => _claims;
  List<User> get users => _users;

  AppState() {
    _initSampleData();
  }

  void _initSampleData() {
    // Admin user
    var admin = User(
      id: 'admin_1',
      name: 'Campus Admin',
      email: 'admin@campus.edu',
      phone: '+12345678901',
      passwordHash: Validators.hashPassword('Admin123!'),
      role: UserRole.admin,
    );

    // Regular user
    var user1 = User(
      id: 'user_1',
      name: 'Alex Johnson',
      email: 'alex@student.edu',
      phone: '+19876543210',
      passwordHash: Validators.hashPassword('Student123!'),
      role: UserRole.user,
    );

    _users = [admin, user1];

    _items = [
      Item(
        id: 'item_101',
        title: 'MacBook Pro M2 Silver',
        description: 'Left in Library 2nd floor silent zone.',
        category: 'Electronics',
        location: 'Main Library',
        date: '2023-11-01',
        estimatedValue: '1200',
        type: ItemType.found,
        userId: 'user_1',
        userName: 'Alex Johnson',
        qrVerificationCode: 'QR_ITEM_101_CLAIM_VERIFY',
      ),
      Item(
        id: 'item_102',
        title: 'Blue Hydro Flask Bottle',
        description: 'Scratched bottom with campus sticker.',
        category: 'Personal Items',
        location: 'Student Center',
        date: '2023-11-03',
        estimatedValue: '25',
        type: ItemType.lost,
        userId: 'user_1',
        userName: 'Alex Johnson',
        qrVerificationCode: 'QR_ITEM_102_CLAIM_VERIFY',
      ),
    ];

    _claims = [];
  }

  // Authentication
  bool register(String name, String email, String phone, String password) {
    if (_users.any((u) => u.email == email)) return false;
    var newUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      passwordHash: Validators.hashPassword(password),
      role: UserRole.user,
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  bool login(String email, String password) {
    var hash = Validators.hashPassword(password);
    var index = _users.indexWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase() && u.passwordHash == hash,
    );
    if (index != -1) {
      _currentUser = _users[index];
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Item Management
  void addItem({
    required String title,
    required String description,
    required String category,
    required String location,
    required String date,
    required String estimatedValue,
    required ItemType type,
  }) {
    if (_currentUser == null) return;
    String id = 'item_${DateTime.now().millisecondsSinceEpoch}';
    var newItem = Item(
      id: id,
      title: title,
      description: description,
      category: category,
      location: location,
      date: date,
      estimatedValue: estimatedValue,
      type: type,
      userId: _currentUser!.id,
      userName: _currentUser!.name,
      qrVerificationCode: 'QR_${id}_VERIFY',
    );
    _items.add(newItem);
    notifyListeners();
  }

  void updateItem(Item item) {
    int idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      notifyListeners();
    }
  }

  void deleteItem(String itemId) {
    _items.removeWhere((i) => i.id == itemId);
    _claims.removeWhere((c) => c.itemId == itemId);
    notifyListeners();
  }

  // Claim Requests
  bool submitClaim(Item item, String proof) {
    if (_currentUser == null) return false;
    if (_claims.any((c) => c.itemId == item.id && c.claimantId == _currentUser!.id)) {
      return false; // Already submitted
    }
    String claimId = 'claim_${DateTime.now().millisecondsSinceEpoch}';
    var newClaim = Claim(
      id: claimId,
      itemId: item.id,
      itemTitle: item.title,
      claimantId: _currentUser!.id,
      claimantName: _currentUser!.name,
      proofDescription: proof,
      qrCode: item.qrVerificationCode,
    );
    _claims.add(newClaim);
    notifyListeners();
    return true;
  }

  void updateClaimStatus(String claimId, ClaimStatus status) {
    int idx = _claims.indexWhere((c) => c.id == claimId);
    if (idx != -1) {
      _claims[idx].status = status;
      if (status == ClaimStatus.approved || status == ClaimStatus.verified) {
        int itemIdx = _items.indexWhere((i) => i.id == _claims[idx].itemId);
        if (itemIdx != -1) {
          _items[itemIdx].status =
              status == ClaimStatus.verified ? ItemStatus.verified : ItemStatus.claimed;
        }
      }
      notifyListeners();
    }
  }

  bool verifyQR(String qrData) {
    int idx = _claims.indexWhere((c) => c.qrCode == qrData);
    if (idx != -1) {
      _claims[idx].status = ClaimStatus.verified;
      int itemIdx = _items.indexWhere((i) => i.id == _claims[idx].itemId);
      if (itemIdx != -1) {
        _items[itemIdx].status = ItemStatus.verified;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Admin User Management
  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }
}
