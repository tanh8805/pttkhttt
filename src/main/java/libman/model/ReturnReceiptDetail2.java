package libman.model;

public class ReturnReceiptDetail2 {
    private int id;
    private BorrowSlipDetail2 borrowSlipDetail;
    private Fine2[] fines;
    private BorrowableDocument2 borrowableDocument;

    public ReturnReceiptDetail2() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public BorrowSlipDetail2 getBorrowSlipDetail() {
        return borrowSlipDetail;
    }

    public void setBorrowSlipDetail(BorrowSlipDetail2 borrowSlipDetail) {
        this.borrowSlipDetail = borrowSlipDetail;
    }

    public BorrowableDocument2 getBorrowableDocument() {
        return borrowableDocument;
    }

    public void setBorrowableDocument(BorrowableDocument2 borrowableDocument) {
        this.borrowableDocument = borrowableDocument;
    }

    public Fine2[] getFines() {
        return fines;
    }

    public void setFines(Fine2[] fines) {
        this.fines = fines;
    }
}
