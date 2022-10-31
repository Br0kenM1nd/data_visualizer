part of 'data_bloc.dart';

enum DataType { names, times, points }

abstract class DataState extends Equatable {
  const DataState();
}

class DataInitial extends DataState {
  const DataInitial();

  @override
  List<Object> get props => [];
}

class DataParsed extends DataState {
  final Map<DataType, dynamic> data;

  const DataParsed({required this.data});

  @override
  List<Object?> get props => [data];
}

class DataError extends DataState {
  final Exception error;

  const DataError(this.error);

  @override
  List<Object> get props => [error];
}
