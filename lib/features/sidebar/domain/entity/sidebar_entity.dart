import 'package:equatable/equatable.dart';

class SideBarEntity extends Equatable {
  final String name;
  final String? permission;
  final bool hasAccess;
  final List<SideBarEntity>? subItems;

  const SideBarEntity({
    required this.name,
    required this.hasAccess,
    this.permission,
    this.subItems,
  });

  @override
  List<Object?> get props => [name, permission, hasAccess, subItems];
}
