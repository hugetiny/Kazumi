// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CollectState {
  List<CollectedBangumi> get collectibles => throw _privateConstructorUsedError;
  bool get syncing => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CollectStateCopyWith<CollectState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectStateCopyWith<$Res> {
  factory $CollectStateCopyWith(
          CollectState value, $Res Function(CollectState) then) =
      _$CollectStateCopyWithImpl<$Res, CollectState>;
  @useResult
  $Res call({List<CollectedBangumi> collectibles, bool syncing});
}

/// @nodoc
class _$CollectStateCopyWithImpl<$Res, $Val extends CollectState>
    implements $CollectStateCopyWith<$Res> {
  _$CollectStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? collectibles = null,
    Object? syncing = null,
  }) {
    return _then(_value.copyWith(
      collectibles: null == collectibles
          ? _value.collectibles
          : collectibles // ignore: cast_nullable_to_non_nullable
              as List<CollectedBangumi>,
      syncing: null == syncing
          ? _value.syncing
          : syncing // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CollectStateImplCopyWith<$Res>
    implements $CollectStateCopyWith<$Res> {
  factory _$$CollectStateImplCopyWith(
          _$CollectStateImpl value, $Res Function(_$CollectStateImpl) then) =
      __$$CollectStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CollectedBangumi> collectibles, bool syncing});
}

/// @nodoc
class __$$CollectStateImplCopyWithImpl<$Res>
    extends _$CollectStateCopyWithImpl<$Res, _$CollectStateImpl>
    implements _$$CollectStateImplCopyWith<$Res> {
  __$$CollectStateImplCopyWithImpl(
      _$CollectStateImpl _value, $Res Function(_$CollectStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? collectibles = null,
    Object? syncing = null,
  }) {
    return _then(_$CollectStateImpl(
      collectibles: null == collectibles
          ? _value._collectibles
          : collectibles // ignore: cast_nullable_to_non_nullable
              as List<CollectedBangumi>,
      syncing: null == syncing
          ? _value.syncing
          : syncing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$CollectStateImpl implements _CollectState {
  const _$CollectStateImpl(
      {final List<CollectedBangumi> collectibles = const [],
      this.syncing = false})
      : _collectibles = collectibles;

  final List<CollectedBangumi> _collectibles;
  @override
  @JsonKey()
  List<CollectedBangumi> get collectibles {
    if (_collectibles is EqualUnmodifiableListView) return _collectibles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_collectibles);
  }

  @override
  @JsonKey()
  final bool syncing;

  @override
  String toString() {
    return 'CollectState(collectibles: $collectibles, syncing: $syncing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectStateImpl &&
            const DeepCollectionEquality()
                .equals(other._collectibles, _collectibles) &&
            (identical(other.syncing, syncing) || other.syncing == syncing));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_collectibles), syncing);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectStateImplCopyWith<_$CollectStateImpl> get copyWith =>
      __$$CollectStateImplCopyWithImpl<_$CollectStateImpl>(this, _$identity);
}

abstract class _CollectState implements CollectState {
  const factory _CollectState(
      {final List<CollectedBangumi> collectibles,
      final bool syncing}) = _$CollectStateImpl;

  @override
  List<CollectedBangumi> get collectibles;
  @override
  bool get syncing;
  @override
  @JsonKey(ignore: true)
  _$$CollectStateImplCopyWith<_$CollectStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
