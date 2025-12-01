import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { TicketViewerComponent } from './ticket-viewer/ticket-viewer.component';
import { KnowledgebaseEditorComponent } from './knowledgebase-editor/knowledgebase-editor.component';
import { LiveLogsComponent } from './live-logs/live-logs.component';

@NgModule({
  declarations: [
    AppComponent,
    TicketViewerComponent,
    KnowledgebaseEditorComponent,
    LiveLogsComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    FormsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
