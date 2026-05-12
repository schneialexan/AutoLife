import 'dart:async';

import 'package:meta/meta.dart';

import 'task.dart';
import 'task_dependency.dart';
import 'task_list.dart';

/// Calendar + task persistence + streaming reads (phase 3.3).
abstract class TaskRepository {
  Stream<List<TaskList>> watchLists(String familyId);

  Stream<List<Task>> watchFamilyTasks(String familyId);

  Stream<List<Task>> watchListTasks({
    required String familyId,
    required String listId,
  });

  Future<void> upsertList(TaskList list);

  Future<void> upsertTask(Task task);

  Future<void> deleteTask({required String familyId, required String taskId});

  Stream<List<TaskDependency>> watchDependencies(String familyId);

  Future<void> addDependency(TaskDependency edge);

  Future<void> removeDependency({
    required String familyId,
    required String taskId,
    required String prerequisiteTaskId,
  });

  Future<Task?> getTask({required String familyId, required String taskId});
}

@immutable
final class MemoryTaskRepository implements TaskRepository {
  final Map<String, TaskList> _lists = {};
  final Map<String, Task> _tasks = {};
  final Map<String, TaskDependency> _deps = {};
  final StreamController<void> _signal = StreamController.broadcast();

  void _emit() => _signal.add(null);

  @override
  Stream<List<TaskList>> watchLists(String familyId) async* {
    yield _listsForFamily(familyId);
    await for (final _ in _signal.stream) {
      yield _listsForFamily(familyId);
    }
  }

  List<TaskList> _listsForFamily(String familyId) => _lists.values
      .where((l) => l.familyId == familyId && !l.archived)
      .toList()
    ..sort((a, b) => a.position.compareTo(b.position));

  @override
  Stream<List<Task>> watchFamilyTasks(String familyId) async* {
    yield _tasksForFamily(familyId);
    await for (final _ in _signal.stream) {
      yield _tasksForFamily(familyId);
    }
  }

  List<Task> _tasksForFamily(String familyId) =>
      _tasks.values.where((t) => t.familyId == familyId).toList();

  @override
  Stream<List<Task>> watchListTasks({
    required String familyId,
    required String listId,
  }) async* {
    yield _tasksForList(familyId, listId);
    await for (final _ in _signal.stream) {
      yield _tasksForList(familyId, listId);
    }
  }

  List<Task> _tasksForList(String familyId, String listId) => _tasks.values
      .where((t) => t.familyId == familyId && t.listId == listId)
      .toList();

  @override
  Future<void> upsertList(TaskList list) async {
    _lists[list.id] = list;
    _emit();
  }

  @override
  Future<void> upsertTask(Task task) async {
    _tasks[task.id] = task;
    _emit();
  }

  @override
  Future<void> deleteTask({required String familyId, required String taskId}) async {
    final t = _tasks[taskId];
    if (t != null && t.familyId == familyId) {
      _tasks.remove(taskId);
      _deps.removeWhere((_, d) => d.taskId == taskId || d.prerequisiteTaskId == taskId);
    }
    _emit();
  }

  @override
  Stream<List<TaskDependency>> watchDependencies(String familyId) async* {
    yield _depsForFamily(familyId);
    await for (final _ in _signal.stream) {
      yield _depsForFamily(familyId);
    }
  }

  List<TaskDependency> _depsForFamily(String familyId) => _deps.values
      .where((d) => d.familyId == familyId)
      .toList();

  @override
  Future<void> addDependency(TaskDependency edge) async {
    _deps[edge.id] = edge;
    _emit();
  }

  @override
  Future<void> removeDependency({
    required String familyId,
    required String taskId,
    required String prerequisiteTaskId,
  }) async {
    _deps.removeWhere(
      (_, d) =>
          d.familyId == familyId &&
          d.taskId == taskId &&
          d.prerequisiteTaskId == prerequisiteTaskId,
    );
    _emit();
  }

  @override
  Future<Task?> getTask({required String familyId, required String taskId}) async {
    final t = _tasks[taskId];
    if (t == null || t.familyId != familyId) return null;
    return t;
  }

  /// Seed demo UX / tests.
  void seedLists(Iterable<TaskList> lists) {
    for (final l in lists) {
      _lists[l.id] = l;
    }
    _emit();
  }

  void seedTasks(Iterable<Task> tasks) {
    for (final t in tasks) {
      _tasks[t.id] = t;
    }
    _emit();
  }

  void seedDependencies(Iterable<TaskDependency> deps) {
    for (final d in deps) {
      _deps[d.id] = d;
    }
    _emit();
  }

  List<Task> snapshotTasks(String familyId) => _tasksForFamily(familyId);

  List<TaskList> snapshotLists(String familyId) => _listsForFamily(familyId);

  List<TaskDependency> snapshotDependencies(String familyId) =>
      _depsForFamily(familyId);
}
