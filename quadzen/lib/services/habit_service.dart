import '../models/habit_model.dart';
import './supabase_service.dart';

class HabitService {
  static Future<List<HabitModel>> getHabits() async {
    try {
      final client = await SupabaseService.client;
      final response = await client
          .from('habits')
          .select('*')
          .eq('user_id', client.auth.currentUser?.id ?? '')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return (response as List)
          .map((habit) => HabitModel.fromJson(habit))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch habits: $error');
    }
  }

  static Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final client = await SupabaseService.client;
      final response = await client
          .from('habits')
          .insert(habit.toJson()..['user_id'] = client.auth.currentUser?.id)
          .select()
          .single();
      return HabitModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create habit: $error');
    }
  }

  static Future<HabitModel> updateHabit(HabitModel habit) async {
    try {
      final client = await SupabaseService.client;
      final response = await client
          .from('habits')
          .update(habit.toJson())
          .eq('id', habit.id)
          .eq('user_id', client.auth.currentUser?.id ?? '')
          .select()
          .single();
      return HabitModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update habit: $error');
    }
  }

  static Future<void> deleteHabit(String habitId) async {
    try {
      final client = await SupabaseService.client;
      await client
          .from('habits')
          .update({'is_active': false})
          .eq('id', habitId)
          .eq('user_id', client.auth.currentUser?.id ?? '');
    } catch (error) {
      throw Exception('Failed to delete habit: $error');
    }
  }

  static Future<void> logHabit(String habitId, DateTime date,
      {int count = 1}) async {
    try {
      final client = await SupabaseService.client;
      await client.from('habit_logs').upsert({
        'habit_id': habitId,
        'date': date.toIso8601String().split('T')[0],
        'count': count,
      });
    } catch (error) {
      throw Exception('Failed to log habit: $error');
    }
  }

  static Future<List<Map<String, dynamic>>> getHabitLogs(String habitId,
      {int days = 30}) async {
    try {
      final client = await SupabaseService.client;
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await client
          .from('habit_logs')
          .select('*')
          .eq('habit_id', habitId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      return (response as List)
          .map((log) => log as Map<String, dynamic>)
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch habit logs: $error');
    }
  }

  static Future<int> getHabitStreak(String habitId) async {
    try {
      final client = await SupabaseService.client;
      final logs = await client
          .from('habit_logs')
          .select('date')
          .eq('habit_id', habitId)
          .order('date', ascending: false);

      if (logs.isEmpty) return 0;

      int streak = 0;
      DateTime currentDate = DateTime.now();

      for (final log in logs) {
        final logDate = DateTime.parse(log['date']);
        final expectedDate = currentDate.subtract(Duration(days: streak));

        if (logDate.year == expectedDate.year &&
            logDate.month == expectedDate.month &&
            logDate.day == expectedDate.day) {
          streak++;
        } else {
          break;
        }
      }

      return streak;
    } catch (error) {
      throw Exception('Failed to calculate habit streak: $error');
    }
  }
}
