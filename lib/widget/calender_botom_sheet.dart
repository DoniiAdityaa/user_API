import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarBotomSheet extends StatefulWidget {
  const CalendarBotomSheet({super.key, required this.initialDate});
  final DateTime initialDate;

  @override
  State<CalendarBotomSheet> createState() => _CalenderBotomSheetState();
}

class _CalenderBotomSheetState extends State<CalendarBotomSheet> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate;
    _selectedDate = widget.initialDate;
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pilih Tanggal',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 18),

          // Table Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDate,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              // <-- Ganti nama parameter
              setState(() {
                _selectedDate = selectedDay;
                _focusedDate = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  // Mengatur warna teks
                  foregroundColor: Colors.black87,
                  // Mengatur garis tepi
                  side: BorderSide(color: Colors.grey.shade300),
                  // Mengatur bentuk & sudut
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedDate);
                },
                style: ElevatedButton.styleFrom(
                  // Mengatur warna latar
                  backgroundColor: Colors.blue.shade100.withOpacity(0.7),
                  // Mengatur warna teks
                  foregroundColor: Colors.blue.shade800,
                  // Menghilangkan bayangan
                  elevation: 0,
                  // Mengatur bentuk & sudut
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Pilih',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
