import '../models/task_model.dart';
import './supabase_service.dart';

class TaskService {
  static Future<List<TaskModel>> getTasks({
    DateTime? date,
    String? status,
    int? limit,
  }) async {
    try {
      final client = await SupabaseService.client;
      var query = client
          .from('tasks')
          .select('*')
          .eq('user_id', client.auth.currentUser?.id ?? '');

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .gte('created_at', startOfDay.toIso8601String())
            .lt('created_at', endOfDay.toIso8601String());
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit ?? 100);
      return (response as List)
          .map((task) => TaskModel.fromJson(task))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch tasks: $error');
    }
  }

  static Future<TaskModel> createTask(TaskModel task) async {
    try {
      final client = await SupabaseService.client;
      final response = await client
          .from('tasks')
          .insert(task.toJson()..['user_id'] = client.auth.currentUser?.id)
          .select()
          .single();
      return TaskModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create task: $error');
    }
  }

  static Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final client = await SupabaseService.client;
      final response = await client
          .from('tasks')
          .update(task.toJson())
          .eq('id', task.id)
          .eq('user_id', client.auth.currentUser?.id ?? '')
          .select()
          .single();
      return TaskModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update task: $error');
    }
  }

  static Future<void> deleteTask(String taskId) async {
    try {
      final client = await SupabaseService.client;
      await client
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', client.auth.currentUser?.id ?? '');
    } catch (error) {
      throw Exception('Failed to delete task: $error');
    }
  }

  static Future<List<TaskModel>> getTasksByStatus(String status) async {
    try {
      final client = await SupabaseService.client;
      final response = await client
          .from('tasks')
          .select('*')
          .eq('user_id', client.auth.currentUser?.id ?? '')
          .eq('status', status)
          .order('created_at', ascending: false);
      return (response as List)
          .map((task) => TaskModel.fromJson(task))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch tasks by status: $error');
    }
  }

  static Future<Map<String, int>> getTaskStatistics() async {
    try {
      final client = await SupabaseService.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        return {'total': 0, 'completed': 0, 'pending': 0};
      }

      final results = await Future.wait([
        client.from('tasks').select().eq('user_id', userId).count(),
        client
            .from('tasks')
            .select()
            .eq('user_id', userId)
            .eq('status', 'completed')
            .count(),
        client
            .from('tasks')
            .select()
            .eq('user_id', userId)
            .eq('status', 'pending')
            .count()
      ]);

      return {
        'total': results[0].count ?? 0,
        'completed': results[1].count ?? 0,
        'pending': results[2].count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch task statistics: $error');
    }
  }
}
