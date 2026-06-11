export function exportToCSV<T extends Record<string, unknown>>(
  data: T[],
  headers: string[],
  filename: string = 'export'
): void {
  const csvContent = [
    headers.join(','),
    ...data.map((row) =>
      headers.map((header) => {
        const value = row[header];
        const str = String(value ?? '');
        return str.includes(',') || str.includes('"') || str.includes('\n')
          ? `"${str.replace(/"/g, '""')}"`
          : str;
      }).join(',')
    ),
  ].join('\n');

  const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `${filename}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
}

export function exportToPDF<T extends Record<string, unknown>>(
  data: T[],
  headers: string[],
  title: string,
  filename: string = 'export'
): void {
  const rows = data
    .map(
      (row) =>
        `<tr>${headers
          .map((header) => `<td style="border:1px solid #ddd;padding:8px;text-align:left">${row[header] ?? ''}</td>`)
          .join('')}</tr>`
    )
    .join('');

  const html = `
    <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; }
          h1 { font-size: 18px; margin-bottom: 16px; }
          table { width: 100%; border-collapse: collapse; }
          th { background: #f1f5f9; border: 1px solid #ddd; padding: 8px; text-align: left; font-size: 12px; }
          td { font-size: 12px; }
        </style>
      </head>
      <body>
        <h1>${title}</h1>
        <table>
          <thead><tr>${headers.map((h) => `<th>${h}</th>`).join('')}</tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </body>
    </html>
  `;

  const blob = new Blob([html], { type: 'application/pdf' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `${filename}.pdf`;
  link.click();
  URL.revokeObjectURL(link.href);
}

export function exportToExcel<T extends Record<string, unknown>>(
  data: T[],
  headers: string[],
  filename: string = 'export'
): void {
  const xml = `
    <?xml version="1.0" encoding="UTF-8"?>
    <?mso-application progid="Excel.Sheet"?>
    <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
      xmlns:o="urn:schemas-microsoft-com:office:office"
      xmlns:x="urn:schemas-microsoft-com:office:excel"
      xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
      <Worksheet ss:Name="Sheet1">
        <Table>
          <Row>
            ${headers.map((h) => `<Cell><Data ss:Type="String">${h}</Data></Cell>`).join('')}
          </Row>
          ${data
            .map(
              (row) =>
                `<Row>${headers
                  .map((header) => {
                    const val = row[header];
                    const isNum = typeof val === 'number';
                    return `<Cell><Data ss:Type="${isNum ? 'Number' : 'String'}">${val ?? ''}</Data></Cell>`;
                  })
                  .join('')}</Row>`
            )
            .join('')}
        </Table>
      </Worksheet>
    </Workbook>
  `;

  const blob = new Blob([xml], { type: 'application/vnd.ms-excel' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `${filename}.xls`;
  link.click();
  URL.revokeObjectURL(link.href);
}
