import 'package:autolife_core/autolife_core.dart';

/// Thrown when prerequisite edges form a cycle.
class TaskDependencyCycleException implements Exception {
  TaskDependencyCycleException(this.message);
  final String message;
  @override
  String toString() => 'TaskDependencyCycleException: $message';
}

/// Computes locked tasks and validates DAG of prerequisites.
class DependencyResolver {
  const DependencyResolver();

  static Map<String, Set<String>> _prereqMap(Iterable<TaskDependency> edges) {
    final m = <String, Set<String>>{};
    for (final e in edges) {
      m.putIfAbsent(e.taskId, () => <String>{}).add(e.prerequisiteTaskId);
    }
    return m;
  }

  /// Transitive prerequisite task ids for [taskId] (excluding [taskId]).
  Set<String> transitivePrerequisites(
    String taskId,
    List<TaskDependency> edges,
  ) {
    validateAcyclic(edges);
    final prereqs = _prereqMap(edges);
    final out = <String>{};
    final queue = List<String>.from(prereqs[taskId] ?? const <String>{});
    var i = 0;
    while (i < queue.length) {
      final c = queue[i++];
      if (!out.add(c)) continue;
      for (final p in prereqs[c] ?? const <String>{}) {
        queue.add(p);
      }
    }
    return out;
  }

  bool isLocked({
    required Task task,
    required List<Task> allTasks,
    required List<TaskDependency> edges,
  }) {
    if (task.status == TaskStatus.completed) return false;
    final byId = {for (final t in allTasks) t.id: t};
    final pres = transitivePrerequisites(task.id, edges);
    for (final pid in pres) {
      final t = byId[pid];
      if (t != null && t.status != TaskStatus.completed) return true;
    }
    return false;
  }

  /// Validates no cycle exists for the full graph; call after every edge mutation.
  void validateAcyclic(List<TaskDependency> edges) {
    final graph = <String, Set<String>>{};
    for (final e in edges) {
      graph.putIfAbsent(e.taskId, () => <String>{}).add(e.prerequisiteTaskId);
    }
    final visiting = <String>{};
    final visited = <String>{};

    void dfs(String n) {
      if (visited.contains(n)) return;
      if (visiting.contains(n)) {
        throw TaskDependencyCycleException('Cycle involving $n');
      }
      visiting.add(n);
      for (final p in graph[n] ?? const <String>{}) {
        dfs(p);
      }
      visiting.remove(n);
      visited.add(n);
    }

    for (final n in graph.keys) {
      dfs(n);
    }
  }
}
