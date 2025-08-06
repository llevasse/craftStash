import 'package:craft_stash/class/patterns/pattern_row.dart' as patternRow;

class PatternRowRepository {
  const PatternRowRepository();

  Future<patternRow.PatternRow> getPatternRowById({required int id}) async {
    patternRow.PatternRow row = await patternRow.getPatternRowByRowId(id);
    return row;
  }

  Future<int> insertRow({required int partId}) async {
    patternRow.PatternRow row = patternRow.PatternRow(
      partId: partId,
      startRow: 0,
      numberOfRows: 0,
      stitchesPerRow: 0,
    );
    return await patternRow.insertPatternRowInDb(row);
  }
}
