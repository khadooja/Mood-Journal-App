import '../models/mood_option.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JournalSearchBar extends StatefulWidget {
  final ValueChanged<String> onTextChanged;
  final ValueChanged<int?> onMoodChanged;

  const JournalSearchBar({
    super.key,
    required this.onTextChanged,
    required this.onMoodChanged,
  });

  @override
  State<JournalSearchBar> createState() => _JournalSearchBarState();
}

class _JournalSearchBarState extends State<JournalSearchBar> {
  final TextEditingController _controller = TextEditingController();
  int? _selectedMood;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectMood(int index) {
    setState(() {
      // Tap same mood again to deselect
      _selectedMood = _selectedMood == index ? null : index;
    });
    widget.onMoodChanged(_selectedMood);
  }

  void _clear() {
    _controller.clear();
    setState(() => _selectedMood = null);
    widget.onTextChanged('');
    widget.onMoodChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter =
        _controller.text.isNotEmpty || _selectedMood != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Text field ────────────────────────────────────
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E5F5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6FCD).withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            onChanged: widget.onTextChanged,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF2D2B55),
            ),
            decoration: InputDecoration(
              hintText: 'Search entries...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFBBB7DF),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: Color(0xFF9D95C7),
              ),
              suffixIcon: hasFilter
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF9D95C7),
                      ),
                      onPressed: _clear,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ── Mood filter pills ─────────────────────────────
        Row(
          children: List.generate(kMoodOptions.length, (i) {
            final mood = kMoodOptions[i];
            final isSelected = _selectedMood == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _selectMood(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? mood.lightColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? mood.color
                          : const Color(0xFFE8E5F5),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mood.emoji,
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        Text(
                          mood.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: mood.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}