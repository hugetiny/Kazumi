// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'info_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$InfoState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get metadataLoading => throw _privateConstructorUsedError;
  List<CommentItem> get commentsList => throw _privateConstructorUsedError;
  List<CharacterItem> get characterList => throw _privateConstructorUsedError;
  List<StaffFullItem> get staffList => throw _privateConstructorUsedError;
  BangumiItem? get bangumiItem => throw _privateConstructorUsedError;
  MetadataRecord? get metadataRecord => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $InfoStateCopyWith<InfoState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InfoStateCopyWith<$Res> {
  factory $InfoStateCopyWith(InfoState value, $Res Function(InfoState) then) =
      _$InfoStateCopyWithImpl<$Res, InfoState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool metadataLoading,
      List<CommentItem> commentsList,
      List<CharacterItem> characterList,
      List<StaffFullItem> staffList,
      BangumiItem? bangumiItem,
      MetadataRecord? metadataRecord});
}

/// @nodoc
class _$InfoStateCopyWithImpl<$Res, $Val extends InfoState>
    implements $InfoStateCopyWith<$Res> {
  _$InfoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? metadataLoading = null,
    Object? commentsList = null,
    Object? characterList = null,
    Object? staffList = null,
    Object? bangumiItem = freezed,
    Object? metadataRecord = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      metadataLoading: null == metadataLoading
          ? _value.metadataLoading
          : metadataLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      commentsList: null == commentsList
          ? _value.commentsList
          : commentsList // ignore: cast_nullable_to_non_nullable
              as List<CommentItem>,
      characterList: null == characterList
          ? _value.characterList
          : characterList // ignore: cast_nullable_to_non_nullable
              as List<CharacterItem>,
      staffList: null == staffList
          ? _value.staffList
          : staffList // ignore: cast_nullable_to_non_nullable
              as List<StaffFullItem>,
      bangumiItem: freezed == bangumiItem
          ? _value.bangumiItem
          : bangumiItem // ignore: cast_nullable_to_non_nullable
              as BangumiItem?,
      metadataRecord: freezed == metadataRecord
          ? _value.metadataRecord
          : metadataRecord // ignore: cast_nullable_to_non_nullable
              as MetadataRecord?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InfoStateImplCopyWith<$Res>
    implements $InfoStateCopyWith<$Res> {
  factory _$$InfoStateImplCopyWith(
          _$InfoStateImpl value, $Res Function(_$InfoStateImpl) then) =
      __$$InfoStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool metadataLoading,
      List<CommentItem> commentsList,
      List<CharacterItem> characterList,
      List<StaffFullItem> staffList,
      BangumiItem? bangumiItem,
      MetadataRecord? metadataRecord});
}

/// @nodoc
class __$$InfoStateImplCopyWithImpl<$Res>
    extends _$InfoStateCopyWithImpl<$Res, _$InfoStateImpl>
    implements _$$InfoStateImplCopyWith<$Res> {
  __$$InfoStateImplCopyWithImpl(
      _$InfoStateImpl _value, $Res Function(_$InfoStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? metadataLoading = null,
    Object? commentsList = null,
    Object? characterList = null,
    Object? staffList = null,
    Object? bangumiItem = freezed,
    Object? metadataRecord = freezed,
  }) {
    return _then(_$InfoStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      metadataLoading: null == metadataLoading
          ? _value.metadataLoading
          : metadataLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      commentsList: null == commentsList
          ? _value._commentsList
          : commentsList // ignore: cast_nullable_to_non_nullable
              as List<CommentItem>,
      characterList: null == characterList
          ? _value._characterList
          : characterList // ignore: cast_nullable_to_non_nullable
              as List<CharacterItem>,
      staffList: null == staffList
          ? _value._staffList
          : staffList // ignore: cast_nullable_to_non_nullable
              as List<StaffFullItem>,
      bangumiItem: freezed == bangumiItem
          ? _value.bangumiItem
          : bangumiItem // ignore: cast_nullable_to_non_nullable
              as BangumiItem?,
      metadataRecord: freezed == metadataRecord
          ? _value.metadataRecord
          : metadataRecord // ignore: cast_nullable_to_non_nullable
              as MetadataRecord?,
    ));
  }
}

/// @nodoc

class _$InfoStateImpl implements _InfoState {
  const _$InfoStateImpl(
      {this.isLoading = false,
      this.metadataLoading = false,
      final List<CommentItem> commentsList = const [],
      final List<CharacterItem> characterList = const [],
      final List<StaffFullItem> staffList = const [],
      this.bangumiItem,
      this.metadataRecord})
      : _commentsList = commentsList,
        _characterList = characterList,
        _staffList = staffList;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool metadataLoading;
  final List<CommentItem> _commentsList;
  @override
  @JsonKey()
  List<CommentItem> get commentsList {
    if (_commentsList is EqualUnmodifiableListView) return _commentsList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commentsList);
  }

  final List<CharacterItem> _characterList;
  @override
  @JsonKey()
  List<CharacterItem> get characterList {
    if (_characterList is EqualUnmodifiableListView) return _characterList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_characterList);
  }

  final List<StaffFullItem> _staffList;
  @override
  @JsonKey()
  List<StaffFullItem> get staffList {
    if (_staffList is EqualUnmodifiableListView) return _staffList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_staffList);
  }

  @override
  final BangumiItem? bangumiItem;
  @override
  final MetadataRecord? metadataRecord;

  @override
  String toString() {
    return 'InfoState(isLoading: $isLoading, metadataLoading: $metadataLoading, commentsList: $commentsList, characterList: $characterList, staffList: $staffList, bangumiItem: $bangumiItem, metadataRecord: $metadataRecord)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InfoStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.metadataLoading, metadataLoading) ||
                other.metadataLoading == metadataLoading) &&
            const DeepCollectionEquality()
                .equals(other._commentsList, _commentsList) &&
            const DeepCollectionEquality()
                .equals(other._characterList, _characterList) &&
            const DeepCollectionEquality()
                .equals(other._staffList, _staffList) &&
            (identical(other.bangumiItem, bangumiItem) ||
                other.bangumiItem == bangumiItem) &&
            (identical(other.metadataRecord, metadataRecord) ||
                other.metadataRecord == metadataRecord));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      metadataLoading,
      const DeepCollectionEquality().hash(_commentsList),
      const DeepCollectionEquality().hash(_characterList),
      const DeepCollectionEquality().hash(_staffList),
      bangumiItem,
      metadataRecord);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InfoStateImplCopyWith<_$InfoStateImpl> get copyWith =>
      __$$InfoStateImplCopyWithImpl<_$InfoStateImpl>(this, _$identity);
}

abstract class _InfoState implements InfoState {
  const factory _InfoState(
      {final bool isLoading,
      final bool metadataLoading,
      final List<CommentItem> commentsList,
      final List<CharacterItem> characterList,
      final List<StaffFullItem> staffList,
      final BangumiItem? bangumiItem,
      final MetadataRecord? metadataRecord}) = _$InfoStateImpl;

  @override
  bool get isLoading;
  @override
  bool get metadataLoading;
  @override
  List<CommentItem> get commentsList;
  @override
  List<CharacterItem> get characterList;
  @override
  List<StaffFullItem> get staffList;
  @override
  BangumiItem? get bangumiItem;
  @override
  MetadataRecord? get metadataRecord;
  @override
  @JsonKey(ignore: true)
  _$$InfoStateImplCopyWith<_$InfoStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
