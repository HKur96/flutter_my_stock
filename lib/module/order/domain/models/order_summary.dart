class OrderPipelineSummary {
  final int queuedCount;
  final int pickingCount;
  final int waitingVerificationCount;
  final int rePickingCount;
  final int verifiedCount;
  final int packingCount;
  final int readyCount;
  final int doneCount;
  final int cancelledCount;
  final int overdueSlaCount;

  const OrderPipelineSummary({
    this.queuedCount = 0,
    this.pickingCount = 0,
    this.waitingVerificationCount = 0,
    this.rePickingCount = 0,
    this.verifiedCount = 0,
    this.packingCount = 0,
    this.readyCount = 0,
    this.doneCount = 0,
    this.cancelledCount = 0,
    this.overdueSlaCount = 0,
  });

  int get totalActiveOrders =>
      queuedCount +
      pickingCount +
      waitingVerificationCount +
      rePickingCount +
      verifiedCount +
      packingCount +
      readyCount;

  int get totalAllOrders => totalActiveOrders + doneCount + cancelledCount;
}
