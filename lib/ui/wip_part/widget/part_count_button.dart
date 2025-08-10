import 'package:craft_stash/ui/core/widgets/buttons/count_button.dart';
import 'package:craft_stash/ui/wip_part/wip_part_model.dart';

CountButton wipPartMadeCount({required WipPartModel wpm}) {
  return CountButton(
    count: wpm.wipPart!.madeXTime,
    onChange: wpm.setWipPartNb,
    max: wpm.wipPart!.part!.numbersToMake,
    signed: false,
  );
}
