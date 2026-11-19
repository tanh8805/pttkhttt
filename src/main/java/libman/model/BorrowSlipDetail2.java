package libman.model;

public class BorrowSlipDetail2 {
    private int id;
    private BorrowableDocument2 borrowableDocument;

    public BorrowSlipDetail2() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public BorrowableDocument2 getBorrowableDocument() {
        return borrowableDocument;
    }

    public void setBorrowableDocument(BorrowableDocument2 borrowableDocument) {
        this.borrowableDocument = borrowableDocument;
    }
}
