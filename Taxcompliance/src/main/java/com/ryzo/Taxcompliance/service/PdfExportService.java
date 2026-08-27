package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.response.TaxReturnWithUserDTO;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
public class PdfExportService {

    private static final float MARGIN = 50f;
    private static final float PAGE_WIDTH = PDRectangle.LETTER.getWidth();
    private static final float LINE_HEIGHT = 16f;
    private static final int WRAP_WIDTH = 100;

    public byte[] exportTaxReturnsPdf(List<TaxReturnWithUserDTO> taxReturns) throws IOException {
        log.info("Generating PDF for {} tax returns", taxReturns.size());

        try (PDDocument doc = new PDDocument()) {
            Writer writer = new Writer(doc);

            writer.title("Tax Returns Report");
            writer.field("Filed By", "Tax Compliance System");
            writer.field("Number of Returns", String.valueOf(taxReturns.size()));
            writer.blank();

            for (TaxReturnWithUserDTO dto : taxReturns) {
                writer.section(formTitle(dto));
                writeFormFields(writer, dto);
                writer.blank();
            }

            writer.close();

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            doc.save(out);
            return out.toByteArray();
        }
    }

    private void writeFormFields(Writer writer, TaxReturnWithUserDTO dto) throws IOException {
        writer.section("A. Taxpayer Information");
        writer.field("Full Name", dto.getFullName());
        writer.field("TIN Number", dto.getTinNumber());
        writer.field("Mobile Number", dto.getMobileNumber());
        writer.field("Email", dto.getEmail());

        writer.section("B. Filing Details");
        writer.field("Filing ID", dto.getFilingId());
        writer.field("Assessment Year", dto.getAssessmentYear());
        writer.field("Filing Type", dto.getFilingType());
        writer.field("Status", dto.getStatus());
        writer.field("Submission Date", dto.getSubmissionDate() != null ? dto.getSubmissionDate().toString() : "-");
        writer.field("Acknowledgment Number", dto.getAcknowledgmentNumber());

        writer.section("C. Income & Tax Computation");
        writer.field("Total Income", money(dto.getTotalIncome()));
        writer.field("Deductions", money(dto.getDeductions()));
        writer.field("Taxable Income", money(dto.getTaxableIncome()));
        writer.field("Tax Payable", money(dto.getTaxPayable()));
        writer.field("Interest", money(dto.getInterest()));
        writer.field("Penalty", money(dto.getPenalty()));
        writer.field("Total Liability", money(dto.getTotalLiability()));
        writer.field("Tax Paid", money(dto.getTaxPaid()));
        writer.field("Refund Amount", money(dto.getRefundAmount()));
    }

    private static String formTitle(TaxReturnWithUserDTO dto) {
        String filingId = dto.getFilingId();
        if (filingId == null) {
            filingId = dto.getId() != null ? "#" + dto.getId() : "(unknown)";
        }
        return "Tax Form " + filingId;
    }

    private static String money(BigDecimal value) {
        return value != null ? "TZS " + value.toPlainString() : "-";
    }

    private final class Writer implements Closeable {
        private final PDDocument doc;
        private PDPage page;
        private PDPageContentStream cs;
        private float y;

        Writer(PDDocument doc) throws IOException {
            this.doc = doc;
            newPage();
        }

        private void newPage() throws IOException {
            if (cs != null) {
                cs.close();
            }
            page = new PDPage(PDRectangle.LETTER);
            doc.addPage(page);
            cs = new PDPageContentStream(doc, page);
            y = 745f;
        }

        private void ensureSpace(float needed) throws IOException {
            if (y - needed < MARGIN) {
                newPage();
            }
        }

        void title(String text) throws IOException {
            ensureSpace(30);
            beginText(PDType1Font.HELVETICA_BOLD, 14, text);
            y -= 26;
        }

        void section(String text) throws IOException {
            ensureSpace(40);
            cs.setStrokingColor(0, 0, 0);
            cs.moveTo(MARGIN, y - 4);
            cs.lineTo(PAGE_WIDTH - MARGIN, y - 4);
            cs.stroke();
            beginText(PDType1Font.HELVETICA_BOLD, 12, text);
            y -= 24;
        }

        void field(String label, String value) throws IOException {
            String text = label + ": " + (value == null ? "-" : value);
            for (String part : wrap(text, WRAP_WIDTH)) {
                ensureSpace(LINE_HEIGHT);
                beginText(PDType1Font.HELVETICA, 10, part);
                y -= LINE_HEIGHT;
            }
        }

        void blank() throws IOException {
            ensureSpace(LINE_HEIGHT);
            y -= LINE_HEIGHT;
        }

        private void beginText(PDType1Font font, float size, String text) throws IOException {
            cs.beginText();
            cs.setFont(font, size);
            cs.newLineAtOffset(MARGIN, y);
            cs.showText(text);
            cs.endText();
        }

        @Override
        public void close() throws IOException {
            cs.close();
        }
    }

    private static List<String> wrap(String text, int max) {
        List<String> lines = new ArrayList<>();
        if (text == null || text.isEmpty()) {
            lines.add("");
            return lines;
        }
        while (text.length() > max) {
            int idx = text.lastIndexOf(' ', max);
            if (idx <= 0) {
                idx = max;
            }
            lines.add(text.substring(0, idx).trim());
            text = text.substring(idx).trim();
        }
        if (!text.isEmpty()) {
            lines.add(text);
        }
        return lines;
    }
}