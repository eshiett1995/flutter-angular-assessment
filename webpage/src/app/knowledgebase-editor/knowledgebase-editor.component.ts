import { Component } from '@angular/core';

@Component({
  selector: 'app-knowledgebase-editor',
  templateUrl: './knowledgebase-editor.component.html',
  styleUrls: ['./knowledgebase-editor.component.css']
})
export class KnowledgebaseEditorComponent {
  content: string = `# Knowledge Base Article

Write your article here using Markdown syntax.

## Features

- **Bold text**
- *Italic text*
- Lists and bullet points
- Code blocks

## Example Code

\`\`\`javascript
function example() {
  console.log('Hello World');
}
\`\`\`

## Tips

1. Use clear headings
2. Add examples
3. Keep it concise`;

  previewMode: boolean = false;
  saved: boolean = false;

  togglePreview() {
    this.previewMode = !this.previewMode;
  }

  saveArticle() {
    // Simulate save action
    this.saved = true;
    setTimeout(() => {
      this.saved = false;
    }, 3000);
  }

  getPreviewHtml(): string {
    // Simple markdown to HTML conversion for preview
    let html = this.content
      .replace(/^# (.*$)/gim, '<h1 class="text-3xl font-bold mb-4">$1</h1>')
      .replace(/^## (.*$)/gim, '<h2 class="text-2xl font-bold mt-6 mb-3">$1</h2>')
      .replace(/^### (.*$)/gim, '<h3 class="text-xl font-bold mt-4 mb-2">$1</h3>')
      .replace(/\*\*(.*?)\*\*/gim, '<strong>$1</strong>')
      .replace(/\*(.*?)\*/gim, '<em>$1</em>')
      .replace(/`([^`]+)`/gim, '<code class="bg-gray-200 px-1 py-0.5 rounded">$1</code>')
      .replace(/```[\s\S]*?```/gim, (match) => {
        const code = match.replace(/```/g, '').trim();
        return `<pre class="bg-gray-800 text-green-400 p-4 rounded-lg overflow-x-auto my-4"><code>${code}</code></pre>`;
      })
      .replace(/^- (.*$)/gim, '<li class="ml-4">$1</li>')
      .replace(/^(\d+)\. (.*$)/gim, '<li class="ml-4">$1. $2</li>')
      .replace(/\n/g, '<br>');
    
    return html;
  }
}
