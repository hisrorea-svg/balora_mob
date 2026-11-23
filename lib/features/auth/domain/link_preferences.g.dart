// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkPreferences)
final linkPreferencesProvider = LinkPreferencesProvider._();

final class LinkPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<LinkPreferences>,
          LinkPreferences,
          FutureOr<LinkPreferences>
        >
    with $FutureModifier<LinkPreferences>, $FutureProvider<LinkPreferences> {
  LinkPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<LinkPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LinkPreferences> create(Ref ref) {
    return linkPreferences(ref);
  }
}

String _$linkPreferencesHash() => r'1e8a930356c5b6bdfa762a83332733f7f093cf94';
