import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/admin_provider.dart';
import '../../attendee/providers/event_provider.dart';
import '../../../data/models/event_model.dart';

class CreateEditEventScreen extends StatefulWidget {
  final String? eventId;

  const CreateEditEventScreen({super.key, this.eventId});

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _capacityController = TextEditingController(text: '100');
  
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _loadEventData();
    }
  }

  void _loadEventData() async {
    // Ideally fetch fresh data, for now finding from list
    final eventProvider = context.read<EventProvider>();
    final event = eventProvider.events.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => EventModel(
        id: '',
        name: '',
        description: '',

        location: '',
        imageUrl: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        capacity: 0,
        registeredCount: 0,
        status: 'upcoming',
        organizerId: '',
        createdAt: DateTime.now(),
      ),
    );

    if (event.id.isNotEmpty) {
      _nameController.text = event.name;
      _descController.text = event.description;
      _locationController.text = event.location;
        _imageUrlController.text = event.imageUrl ?? '';
      _capacityController.text = event.capacity.toString();
      _startDate = event.startDate;
      _startTime = TimeOfDay.fromDateTime(event.startDate);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final eventDate = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final eventData = {
      'name': _nameController.text,
      'description': _descController.text,
      'location': _locationController.text,
      'imageUrl': _imageUrlController.text,
      'capacity': int.tryParse(_capacityController.text) ?? 100,
      'date': _startDate.toIso8601String(),
      'startTime': '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${(_startTime.hour + 2).toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}', // Default 2 hours
    };

    final provider = context.read<AdminProvider>();
    bool success;

    if (widget.eventId != null) {
      success = await provider.updateEvent(widget.eventId!, eventData);
    } else {
      success = await provider.createEvent(eventData);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(widget.eventId != null ? 'Event updated' : 'Event created')),
        );
        context.pop();
        context.read<EventProvider>().fetchEvents(refresh: true); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Image Preview
            if (_imageUrlController.text.isNotEmpty)
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(_imageUrlController.text),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                ),
              ),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                prefixIcon: Icon(Icons.event),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
            ),
            const SizedBox(height: 16),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(DateFormat.yMMMd().format(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Capacity & Image URL
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      prefixIcon: Icon(Icons.people),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                prefixIcon: Icon(Icons.image),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}), // Update preview
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: isEditing ? 'Update Event' : 'Create Event',
              onPressed: _isLoading ? null : _saveEvent,
              isLoading: _isLoading,
              variant: ButtonVariant.gradient,
            ),
          ],
        ),
      ),
    );
  }
}
