import { Component, OnInit, OnDestroy, ViewChild, ElementRef, AfterViewChecked } from '@angular/core';

interface LogEntry {
  timestamp: Date;
  level: 'INFO' | 'WARN' | 'ERROR' | 'DEBUG';
  message: string;
  source: string;
}

@Component({
  selector: 'app-live-logs',
  templateUrl: './live-logs.component.html',
  styleUrls: ['./live-logs.component.css']
})
export class LiveLogsComponent implements OnInit, OnDestroy, AfterViewChecked {
  @ViewChild('logContainer', { static: false }) logContainer!: ElementRef;
  
  logs: LogEntry[] = [];
  private intervalId: any;
  autoScroll: boolean = true;

  logMessages: string[] = [
    'User login successful',
    'API request processed',
    'Database query executed',
    'Cache updated',
    'Email sent successfully',
    'File uploaded',
    'Authentication token refreshed',
    'Background job started',
    'Webhook received',
    'Payment processed',
    'Export completed',
    'Report generated',
    'Backup initiated',
    'Session expired',
    'Rate limit exceeded',
    'Connection established',
    'Data synchronized',
    'Queue processed',
  ];

  logSources: string[] = [
    'AuthService',
    'APIController',
    'Database',
    'CacheService',
    'EmailService',
    'FileUploader',
    'WebhookHandler',
    'PaymentGateway',
    'BackgroundWorker',
  ];

  ngOnInit() {
    // Initialize with some logs
    this.generateLog();
    this.generateLog();
    this.generateLog();

    // Generate new logs every 2-5 seconds
    this.intervalId = setInterval(() => {
      this.generateLog();
    }, Math.random() * 3000 + 2000);
  }

  ngOnDestroy() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  ngAfterViewChecked() {
    if (this.autoScroll) {
      this.scrollToBottom();
    }
  }

  generateLog() {
    const levels: ('INFO' | 'WARN' | 'ERROR' | 'DEBUG')[] = ['INFO', 'WARN', 'ERROR', 'DEBUG'];
    const level = levels[Math.floor(Math.random() * levels.length)];
    
    // Make errors less frequent
    const actualLevel = Math.random() > 0.85 ? 'ERROR' : 
                       Math.random() > 0.7 ? 'WARN' : 
                       Math.random() > 0.5 ? 'INFO' : 'DEBUG';

    const log: LogEntry = {
      timestamp: new Date(),
      level: actualLevel,
      message: this.logMessages[Math.floor(Math.random() * this.logMessages.length)],
      source: this.logSources[Math.floor(Math.random() * this.logSources.length)]
    };

    this.logs.push(log);
    
    // Keep only last 100 logs
    if (this.logs.length > 100) {
      this.logs.shift();
    }
  }

  scrollToBottom() {
    try {
      if (this.logContainer) {
        this.logContainer.nativeElement.scrollTop = this.logContainer.nativeElement.scrollHeight;
      }
    } catch (err) {
      // Ignore scroll errors
    }
  }

  getLevelClass(level: string): string {
    switch (level) {
      case 'INFO':
        return 'text-blue-600 bg-blue-50 border-blue-200';
      case 'WARN':
        return 'text-yellow-600 bg-yellow-50 border-yellow-200';
      case 'ERROR':
        return 'text-red-600 bg-red-50 border-red-200';
      case 'DEBUG':
        return 'text-gray-600 bg-gray-50 border-gray-200';
      default:
        return 'text-gray-600 bg-gray-50 border-gray-200';
    }
  }

  formatTime(date: Date): string {
    return new Date(date).toLocaleTimeString('en-US', {
      hour12: false,
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      fractionalSecondDigits: 3
    });
  }

  clearLogs() {
    this.logs = [];
  }

  toggleAutoScroll() {
    this.autoScroll = !this.autoScroll;
  }
}
