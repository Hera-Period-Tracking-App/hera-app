import 'tc_001_dodaj_cikel_test.dart' as cycle;
import 'tc_002_dodaj_opombo_test.dart' as note;
import 'tc_003_simptom_tok_test.dart' as symptoms;
import 'tc_004_meja_menstruacije_test.dart' as boundary;
import 'tc_005_urnik_opomnika_test.dart' as reminder;

/// One entrypoint runs the five cases with a single native build/install.
void main() {
  cycle.main();
  note.main();
  symptoms.main();
  boundary.main();
  reminder.main();
}
