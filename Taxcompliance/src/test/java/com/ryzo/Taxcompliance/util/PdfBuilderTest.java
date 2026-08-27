package com.ryzo.Taxcompliance.util;

import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class PdfBuilderTest {

    @Test
    void generatesValidPdf() {
        byte[] pdf = PdfBuilder.simpleDocument("TEST TITLE", List.of("Line one", "Line two"));
        String content = new String(pdf, StandardCharsets.ISO_8859_1);

        assertThat(pdf).isNotEmpty();
        assertThat(content).startsWith("%PDF-1.4");
        assertThat(content.trim()).endsWith("%%EOF");
        assertThat(content).contains("(TEST TITLE)");
        assertThat(content).contains("(Line one)");
        assertThat(content).contains("startxref");
    }

    @Test
    void escapesSpecialCharacters() {
        byte[] pdf = PdfBuilder.simpleDocument("Title (with) parens", List.of("Line (a)"));
        String content = new String(pdf, StandardCharsets.ISO_8859_1);
        assertThat(content).doesNotContain("Title (with) parens) Tj");
        assertThat(content).contains("Title \\(with\\) parens");
    }
}
