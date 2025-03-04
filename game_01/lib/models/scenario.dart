class Scenario {
  final int id;
  final String title;
  final String description;
  final List<String> steps;
  final int difficulty;

  Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    this.difficulty = 1,
  });
}
