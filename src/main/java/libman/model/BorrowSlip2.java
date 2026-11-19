package libman.model;

import java.util.Date;

public class BorrowSlip2 {
    private int id;
    private String borrowCode;
    private Date borrowDate;
    private Date dueDate;
    private Reader2 reader;
    private Librarian2 librarian;
    private BorrowSlipDetail2[] details;

    public BorrowSlip2() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBorrowCode() {
        return borrowCode;
    }

    public void setBorrowCode(String borrowCode) {
        this.borrowCode = borrowCode;
    }

    public Date getBorrowDate() {
        return borrowDate;
    }

    public void setBorrowDate(Date borrowDate) {
        this.borrowDate = borrowDate;
    }

    public Date getDueDate() {
        return dueDate;
    }

    public void setDueDate(Date dueDate) {
        this.dueDate = dueDate;
    }

    public Reader2 getReader() {
        return reader;
    }

    public void setReader(Reader2 reader) {
        this.reader = reader;
    }

    public Librarian2 getLibrarian() {
        return librarian;
    }

    public void setLibrarian(Librarian2 librarian) {
        this.librarian = librarian;
    }

    public BorrowSlipDetail2[] getDetails() {
        return details;
    }

    public void setDetails(BorrowSlipDetail2[] details) {
        this.details = details;
    }
}
