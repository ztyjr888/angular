import 'package:angular_compiler/angular_compiler.dart';
import 'package:barback/barback.dart';
import 'package:build_barback/build_barback.dart';
import 'package:dart_style/dart_style.dart';

import '../../source_gen.dart';
import 'common/eager_transformer_wrapper.dart';
import 'common/formatter.dart' as formatter;
import 'deferred_rewriter/transformer.dart';
import 'reflection_remover/transformer.dart';
import 'stylesheet_compiler/transformer.dart';

/// Replaces Angular 2 mirror use with generated code.
class AngularTransformerGroup extends TransformerGroup {
  AngularTransformerGroup._(Iterable<Iterable> phases) : super(phases) {
    formatter.init(new DartFormatter());
  }

  factory AngularTransformerGroup(CompilerFlags flags) {
    Iterable<Iterable> phases = [
      [new BuilderTransformer(new TemplatePlaceholderBuilder())],
      [new ReflectionRemover(flags)],
      [
        new DeferredRewriter(),
        new StylesheetCompiler(flags),
        new BuilderTransformer(
          createSourceGenTemplateCompiler(flags),
        )
      ],
    ];
    phases =
        phases.map((phase) => phase.map((t) => new EagerTransformerWrapper(t)));
    return new AngularTransformerGroup._(phases);
  }

  factory AngularTransformerGroup.asPlugin(BarbackSettings settings) {
    return new AngularTransformerGroup(
      new CompilerFlags.parseBarback(
        settings,
        defaultTo: new CompilerFlags(
          genDebugInfo: settings.mode == BarbackMode.DEBUG,
          useLegacyStyleEncapsulation: true,
        ),
      ),
    );
  }
}
