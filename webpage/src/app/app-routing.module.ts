import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { TicketViewerComponent } from './ticket-viewer/ticket-viewer.component';
import { KnowledgebaseEditorComponent } from './knowledgebase-editor/knowledgebase-editor.component';
import { LiveLogsComponent } from './live-logs/live-logs.component';

const routes: Routes = [
  { path: '', redirectTo: '/tickets', pathMatch: 'full' },
  { path: 'tickets', component: TicketViewerComponent },
  { path: 'knowledgebase', component: KnowledgebaseEditorComponent },
  { path: 'logs', component: LiveLogsComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
