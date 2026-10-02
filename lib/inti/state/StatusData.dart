enum Status { initial, loading, sukses, kosong, error }

class StatusData<T> {
  final Status status;
  final T? data;
  final String? pesan;

  const StatusData.initial()
      : status = Status.initial,
        data = null,
        pesan = null;

  const StatusData.loading()
      : status = Status.loading,
        data = null,
        pesan = null;

  const StatusData.sukses(T this.data)
      : status = Status.sukses,
        pesan = null;

  const StatusData.kosong()
      : status = Status.kosong,
        data = null,
        pesan = null;

  const StatusData.error(String this.pesan)
      : status = Status.error,
        data = null;

  bool get sedangLoading => status == Status.loading;
  bool get adalahSukses => status == Status.sukses;
  bool get adalahKosong => status == Status.kosong;
  bool get adalahError => status == Status.error;
}
