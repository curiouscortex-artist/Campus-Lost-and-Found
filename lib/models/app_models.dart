enum UserRole { user, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String passwordHash;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.passwordHash,
    this.role = UserRole.user,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'passwordHash': passwordHash,
        'role': role.name,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        passwordHash: json['passwordHash'],
        role: json['role'] == 'admin' ? UserRole.admin : UserRole.user,
      );
}

enum ItemType { lost, found }
enum ItemStatus { open, claimed, verified }

class Item {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String date; // YYYY-MM-DD
  final String estimatedValue; // Numeric string
  final ItemType type;
  ItemStatus status;
  final String userId;
  final String userName;
  final String qrVerificationCode;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.estimatedValue,
    required this.type,
    this.status = ItemStatus.open,
    required this.userId,
    required this.userName,
    required this.qrVerificationCode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'date': date,
        'estimatedValue': estimatedValue,
        'type': type.name,
        'status': status.name,
        'userId': userId,
        'userName': userName,
        'qrVerificationCode': qrVerificationCode,
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        category: json['category'],
        location: json['location'],
        date: json['date'],
        estimatedValue: json['estimatedValue'],
        type: json['type'] == 'lost' ? ItemType.lost : ItemType.found,
        status: ItemStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ItemStatus.open,
        ),
        userId: json['userId'],
        userName: json['userName'],
        qrVerificationCode: json['qrVerificationCode'],
      );
}

enum ClaimStatus { pending, approved, rejected, verified }

class Claim {
  final String id;
  final String itemId;
  final String itemTitle;
  final String claimantId;
  final String claimantName;
  final String proofDescription;
  ClaimStatus status;
  final String qrCode;

  Claim({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.claimantId,
    required this.claimantName,
    required this.proofDescription,
    this.status = ClaimStatus.pending,
    required this.qrCode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'itemTitle': itemTitle,
        'claimantId': claimantId,
        'claimantName': claimantName,
        'proofDescription': proofDescription,
        'status': status.name,
        'qrCode': qrCode,
      };

  factory Claim.fromJson(Map<String, dynamic> json) => Claim(
        id: json['id'],
        itemId: json['itemId'],
        itemTitle: json['itemTitle'],
        claimantId: json['claimantId'],
        claimantName: json['claimantName'],
        proofDescription: json['proofDescription'],
        status: ClaimStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ClaimStatus.pending,
        ),
        qrCode: json['qrCode'],
      );
}
