import 'package:flutter/material.dart';
import '../../../commons/data/models/category.dart';
import '../../../theme/app_theme.dart';

class CategorySidebar extends StatelessWidget {
  final List<Category> categories;
  final int? selectedId;
  final void Function(int? id) onSelect;

  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final roots = categories.where((c) => c.isRoot).toList();
    return Container(
      width: 120,
      color: Colors.white,
      child: ListView(
        children: [
          _CategoryItem(
            label: 'Tous',
            selected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          ...roots.map((cat) => _ExpandableCategoryItem(
                category: cat,
                selectedId: selectedId,
                onSelect: onSelect,
              )),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryItem(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              width: 3,
              color: selected
                  ? AppTheme.primaryGreen
                  : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppTheme.primaryGreen : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _ExpandableCategoryItem extends StatefulWidget {
  final Category category;
  final int? selectedId;
  final void Function(int? id) onSelect;

  const _ExpandableCategoryItem({
    required this.category,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  State<_ExpandableCategoryItem> createState() =>
      _ExpandableCategoryItemState();
}

class _ExpandableCategoryItemState
    extends State<_ExpandableCategoryItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.category.children.isNotEmpty;
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (hasChildren) {
              setState(() => _expanded = !_expanded);
            }
            widget.onSelect(widget.category.id);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: widget.selectedId == widget.category.id
                  ? AppTheme.primaryGreen.withOpacity(0.1)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  width: 3,
                  color: widget.selectedId == widget.category.id
                      ? AppTheme.primaryGreen
                      : Colors.transparent,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: widget.selectedId == widget.category.id
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: widget.selectedId == widget.category.id
                          ? AppTheme.primaryGreen
                          : Colors.black87,
                    ),
                  ),
                ),
                if (hasChildren)
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 16,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
        if (_expanded && hasChildren)
          ...widget.category.children.map((child) => Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _CategoryItem(
                  label: child.name,
                  selected: widget.selectedId == child.id,
                  onTap: () => widget.onSelect(child.id),
                ),
              )),
      ],
    );
  }
}
