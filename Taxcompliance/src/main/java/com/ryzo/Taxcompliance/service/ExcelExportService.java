package com.ryzo.Taxcompliance.service;


import com.ryzo.Taxcompliance.dto.response.TaxReturnWithUserDTO;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@Slf4j
public class ExcelExportService {

    private static final String[] HEADERS = {
            "Filing ID",
            "TIN Number",
            "Taxpayer Name",
            "Email",
            "Mobile Number",
            "Assessment Year",
            "Filing Type",
            "Total Income (TSh)",
            "Deductions (TSh)",
            "Taxable Income (TSh)",
            "Tax Payable (TSh)",
            "Interest (TSh)",
            "Penalty (TSh)",
            "Total Liability (TSh)",
            "Tax Paid (TSh)",
            "Refund Amount (TSh)",
            "Status",
            "Submission Date",
            "Acknowledgment Number"
    };

    private static final String[] HEADERS_WITHOUT_USER = {
            "Filing ID",
            "Assessment Year",
            "Filing Type",
            "Total Income (TSh)",
            "Deductions (TSh)",
            "Taxable Income (TSh)",
            "Tax Payable (TSh)",
            "Interest (TSh)",
            "Penalty (TSh)",
            "Total Liability (TSh)",
            "Tax Paid (TSh)",
            "Refund Amount (TSh)",
            "Status",
            "Submission Date",
            "Acknowledgment Number"
    };

    /**
     * Export tax returns with user details to Excel
     */
    public byte[] exportTaxReturnsWithUser(List<TaxReturnWithUserDTO> taxReturns) throws IOException {
        log.info("Exporting {} tax returns with user details to Excel", taxReturns.size());

        try (Workbook workbook = new XSSFWorkbook()) {
            // Create sheets
            Sheet dataSheet = workbook.createSheet("Tax Returns");
            Sheet summarySheet = workbook.createSheet("Summary");

            // Create styles
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle dateStyle = createDateStyle(workbook);
            CellStyle currencyStyle = createCurrencyStyle(workbook);
            CellStyle statusStyle = createStatusStyle(workbook);

            // Build data sheet
            buildDataSheet(dataSheet, taxReturns, headerStyle, dateStyle, currencyStyle, statusStyle);

            // Build summary sheet
            buildSummarySheet(summarySheet, taxReturns, headerStyle, currencyStyle);

            // Auto-size columns
            autoSizeColumns(dataSheet, HEADERS.length);

            // Write to byte array
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            workbook.write(outputStream);
            return outputStream.toByteArray();
        }
    }

    /**
     * Export tax returns without user details to Excel
     */
    public byte[] exportTaxReturns(List<TaxReturnWithUserDTO> taxReturns) throws IOException {
        log.info("Exporting {} tax returns to Excel", taxReturns.size());

        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Tax Returns");

            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle dateStyle = createDateStyle(workbook);
            CellStyle currencyStyle = createCurrencyStyle(workbook);
            CellStyle statusStyle = createStatusStyle(workbook);

            // Create header row
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < HEADERS_WITHOUT_USER.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(HEADERS_WITHOUT_USER[i]);
                cell.setCellStyle(headerStyle);
            }

            // Populate data
            int rowNum = 1;
            for (TaxReturnWithUserDTO dto : taxReturns) {
                Row row = sheet.createRow(rowNum++);
                fillTaxReturnRowWithoutUser(row, dto, dateStyle, currencyStyle, statusStyle);
            }

            // Auto-size columns
            autoSizeColumns(sheet, HEADERS_WITHOUT_USER.length);

            // Write to byte array
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            workbook.write(outputStream);
            return outputStream.toByteArray();
        }
    }

    /**
     * Build data sheet with user details
     */
    private void buildDataSheet(Sheet sheet, List<TaxReturnWithUserDTO> taxReturns,
                                CellStyle headerStyle, CellStyle dateStyle,
                                CellStyle currencyStyle, CellStyle statusStyle) {

        // Create header row
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < HEADERS.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(HEADERS[i]);
            cell.setCellStyle(headerStyle);
        }

        // Populate data
        int rowNum = 1;
        for (TaxReturnWithUserDTO dto : taxReturns) {
            Row row = sheet.createRow(rowNum++);
            fillTaxReturnRowWithUser(row, dto, dateStyle, currencyStyle, statusStyle);
        }
    }

    /**
     * Fill a row with tax return data (with user details)
     */
    private void fillTaxReturnRowWithUser(Row row, TaxReturnWithUserDTO dto,
                                          CellStyle dateStyle, CellStyle currencyStyle,
                                          CellStyle statusStyle) {
        int col = 0;

        // Tax Return Fields
        createCell(row, col++, dto.getFilingId(), null);
        createCell(row, col++, dto.getTinNumber(), null);
        createCell(row, col++, dto.getFullName(), null);
        createCell(row, col++, dto.getEmail(), null);
        createCell(row, col++, dto.getMobileNumber(), null);
        createCell(row, col++, dto.getAssessmentYear(), null);
        createCell(row, col++, dto.getFilingType(), null);
        createCell(row, col++, dto.getTotalIncome(), currencyStyle);
        createCell(row, col++, dto.getDeductions(), currencyStyle);
        createCell(row, col++, dto.getTaxableIncome(), currencyStyle);
        createCell(row, col++, dto.getTaxPayable(), currencyStyle);
        createCell(row, col++, dto.getInterest(), currencyStyle);
        createCell(row, col++, dto.getPenalty(), currencyStyle);
        createCell(row, col++, dto.getTotalLiability(), currencyStyle);
        createCell(row, col++, dto.getTaxPaid(), currencyStyle);
        createCell(row, col++, dto.getRefundAmount(), currencyStyle);

        // Status with color
        Cell statusCell = row.createCell(col++);
        statusCell.setCellValue(dto.getStatus());
        statusCell.setCellStyle(statusStyle);

        // Date fields
        if (dto.getSubmissionDate() != null) {
            createCell(row, col++, dto.getSubmissionDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")), dateStyle);
        } else {
            createCell(row, col++, "N/A", dateStyle);
        }

        createCell(row, col++, dto.getAcknowledgmentNumber(), null);
    }

    /**
     * Fill a row with tax return data (without user details)
     */
    private void fillTaxReturnRowWithoutUser(Row row, TaxReturnWithUserDTO dto,
                                             CellStyle dateStyle, CellStyle currencyStyle,
                                             CellStyle statusStyle) {
        int col = 0;

        createCell(row, col++, dto.getFilingId(), null);
        createCell(row, col++, dto.getAssessmentYear(), null);
        createCell(row, col++, dto.getFilingType(), null);
        createCell(row, col++, dto.getTotalIncome(), currencyStyle);
        createCell(row, col++, dto.getDeductions(), currencyStyle);
        createCell(row, col++, dto.getTaxableIncome(), currencyStyle);
        createCell(row, col++, dto.getTaxPayable(), currencyStyle);
        createCell(row, col++, dto.getInterest(), currencyStyle);
        createCell(row, col++, dto.getPenalty(), currencyStyle);
        createCell(row, col++, dto.getTotalLiability(), currencyStyle);
        createCell(row, col++, dto.getTaxPaid(), currencyStyle);
        createCell(row, col++, dto.getRefundAmount(), currencyStyle);

        Cell statusCell = row.createCell(col++);
        statusCell.setCellValue(dto.getStatus());
        statusCell.setCellStyle(statusStyle);

        if (dto.getSubmissionDate() != null) {
            createCell(row, col++, dto.getSubmissionDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")), dateStyle);
        } else {
            createCell(row, col++, "N/A", dateStyle);
        }

        createCell(row, col++, dto.getAcknowledgmentNumber(), null);
    }

    /**
     * Build summary sheet
     */
    private void buildSummarySheet(Sheet sheet, List<TaxReturnWithUserDTO> taxReturns,
                                   CellStyle headerStyle, CellStyle currencyStyle) {
        int rowNum = 0;

        // Title
        Row titleRow = sheet.createRow(rowNum++);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("TAX RETURNS SUMMARY REPORT");
        titleCell.setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 3));

        rowNum++; // Empty row

        // Summary statistics
        Row statsRow1 = sheet.createRow(rowNum++);
        statsRow1.createCell(0).setCellValue("Total Returns:");
        statsRow1.createCell(1).setCellValue(taxReturns.size());

        // Count by status
        long completed = taxReturns.stream().filter(t -> "COMPLETED".equals(t.getStatus())).count();
        long submitted = taxReturns.stream().filter(t -> "SUBMITTED".equals(t.getStatus())).count();
        long pending = taxReturns.stream().filter(t -> "DRAFT".equals(t.getStatus())).count();
        long rejected = taxReturns.stream().filter(t -> "REJECTED".equals(t.getStatus())).count();

        Row statsRow2 = sheet.createRow(rowNum++);
        statsRow2.createCell(0).setCellValue("Completed:");
        statsRow2.createCell(1).setCellValue(completed);

        Row statsRow3 = sheet.createRow(rowNum++);
        statsRow3.createCell(0).setCellValue("Submitted:");
        statsRow3.createCell(1).setCellValue(submitted);

        Row statsRow4 = sheet.createRow(rowNum++);
        statsRow4.createCell(0).setCellValue("Pending:");
        statsRow4.createCell(1).setCellValue(pending);

        Row statsRow5 = sheet.createRow(rowNum++);
        statsRow5.createCell(0).setCellValue("Rejected:");
        statsRow5.createCell(1).setCellValue(rejected);

        rowNum++; // Empty row

        // Financial summary
        Row financialTitle = sheet.createRow(rowNum++);
        financialTitle.createCell(0).setCellValue("Financial Summary:");
        financialTitle.getCell(0).setCellStyle(headerStyle);

        BigDecimal totalIncome = taxReturns.stream()
            .map(dto -> dto.getTotalIncome() == null ? BigDecimal.ZERO : dto.getTotalIncome())
            .reduce(BigDecimal.ZERO, (sum, value) -> sum.add(value == null ? BigDecimal.ZERO : value));
        BigDecimal totalTax = taxReturns.stream()
            .map(dto -> dto.getTotalLiability() == null ? BigDecimal.ZERO : dto.getTotalLiability())
            .reduce(BigDecimal.ZERO, (sum, value) -> sum.add(value == null ? BigDecimal.ZERO : value));
        BigDecimal totalPaid = taxReturns.stream()
            .map(dto -> dto.getTaxPaid() == null ? BigDecimal.ZERO : dto.getTaxPaid())
            .reduce(BigDecimal.ZERO, (sum, value) -> sum.add(value == null ? BigDecimal.ZERO : value));
        BigDecimal totalRefund = taxReturns.stream()
            .map(dto -> dto.getRefundAmount() == null ? BigDecimal.ZERO : dto.getRefundAmount())
            .reduce(BigDecimal.ZERO, (sum, value) -> sum.add(value == null ? BigDecimal.ZERO : value));

        Row financialRow1 = sheet.createRow(rowNum++);
        financialRow1.createCell(0).setCellValue("Total Income:");
        financialRow1.createCell(1).setCellValue(totalIncome.toString());
        financialRow1.getCell(1).setCellStyle(currencyStyle);

        Row financialRow2 = sheet.createRow(rowNum++);
        financialRow2.createCell(0).setCellValue("Total Tax Liability:");
        financialRow2.createCell(1).setCellValue(totalTax.toString());
        financialRow2.getCell(1).setCellStyle(currencyStyle);

        Row financialRow3 = sheet.createRow(rowNum++);
        financialRow3.createCell(0).setCellValue("Total Tax Paid:");
        financialRow3.createCell(1).setCellValue(totalPaid.toString());
        financialRow3.getCell(1).setCellStyle(currencyStyle);

        Row financialRow4 = sheet.createRow(rowNum++);
        financialRow4.createCell(0).setCellValue("Total Refund:");
        financialRow4.createCell(1).setCellValue(totalRefund.toString());
        financialRow4.getCell(1).setCellStyle(currencyStyle);

        // Auto-size summary columns
        for (int i = 0; i < 2; i++) {
            sheet.autoSizeColumn(i);
        }
    }

    /**
     * Create a cell with string value
     */
    private void createCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        if (style != null) {
            cell.setCellStyle(style);
        }
    }

    /**
     * Create a cell with BigDecimal value
     */
    private void createCell(Row row, int col, BigDecimal value, CellStyle style) {
        Cell cell = row.createCell(col);
        if (value != null) {
            cell.setCellValue(value.doubleValue());
        } else {
            cell.setCellValue(0.0);
        }
        if (style != null) {
            cell.setCellStyle(style);
        }
    }

    /**
     * Create header cell style
     */
    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.DARK_GREEN.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    /**
     * Create date cell style
     */
    private CellStyle createDateStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        CreationHelper createHelper = workbook.getCreationHelper();
        style.setDataFormat(createHelper.createDataFormat().getFormat("dd/MM/yyyy"));
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }

    /**
     * Create currency cell style
     */
    private CellStyle createCurrencyStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        CreationHelper createHelper = workbook.getCreationHelper();
        style.setDataFormat(createHelper.createDataFormat().getFormat("#,##0.00"));
        style.setAlignment(HorizontalAlignment.RIGHT);
        return style;
    }

    /**
     * Create status cell style with color
     */
    private CellStyle createStatusStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setAlignment(HorizontalAlignment.CENTER);
        // Color will be set per cell based on status value
        return style;
    }

    /**
     * Auto-size columns
     */
    private void autoSizeColumns(Sheet sheet, int columnCount) {
        for (int i = 0; i < columnCount; i++) {
            sheet.autoSizeColumn(i);
        }
    }
}