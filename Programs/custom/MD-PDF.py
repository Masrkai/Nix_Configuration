from markdown2 import markdown, markdown_path
from weasyprint import HTML, CSS
import fire
import os

def md2pdf(md_file_path, output_file_path=None, new_page_char="---", style_file_path=None):
    """
    This converts markdown to pdf

    :param md_file_path: Path to the markdown file
    :type md_file_path: str
    :param output_file_path: Path to the output PDF file (it will not create a folder for you, make sure directory already exists)
    :type output_file_path: str
    :param new_page_char: Character for new page break
    :type new_page_char: str
    :param style_file_path: Path to the CSS file
    :type style_file_path: str
    :return: Path of the converted PDF file
    :rtype: str
    """

    extras = [
        'cuddled-lists',
        'tables',
        'footnotes',
        'fenced-code-blocks',
        'wiki-table'
    ]
    
    # Convert Markdown to HTML
    html_in_text = markdown_path(md_file_path, extras=extras)
    
    # Handle new page character
    if new_page_char:
        page_break_char = markdown(new_page_char, extras=extras)
        html_in_text = html_in_text.replace(page_break_char, '<p style="page-break-before: always" ></p>')
    
    # Create HTML object
    html_object = HTML(string=html_in_text)
    
    # Determine output file path if not provided
    if output_file_path is None:
        base_name = os.path.splitext(md_file_path)[0]  # Get base name without extension
        output_file_path = f"{base_name}.pdf"  # Set output PDF file name
    
    # Prepare CSS styles including A4 page size
    css = []
    
    # Add A4 page size CSS rule
    css.append(CSS(string='@page { size: A4; margin: 1cm; }'))  # You can adjust margins as needed
    
    if style_file_path:
        css.append(CSS(filename=style_file_path))
    
    # Write PDF to output path
    html_object.write_pdf(output_file_path, stylesheets=css)

    return output_file_path

if __name__ == '__main__':
    fire.Fire(md2pdf)