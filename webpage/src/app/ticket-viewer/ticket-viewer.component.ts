import { Component } from '@angular/core';

interface Ticket {
  id: number;
  subject: string;
  status: 'Open' | 'In Progress' | 'Closed';
  createdAt: Date;
}

@Component({
  selector: 'app-ticket-viewer',
  templateUrl: './ticket-viewer.component.html',
  styleUrls: ['./ticket-viewer.component.css']
})
export class TicketViewerComponent {
  selectedFilter: 'All' | 'Open' | 'In Progress' | 'Closed' = 'All';

  tickets: Ticket[] = [
    { id: 1001, subject: 'Login issue on mobile app', status: 'Open', createdAt: new Date('2024-01-15T10:30:00') },
    { id: 1002, subject: 'Payment gateway timeout', status: 'In Progress', createdAt: new Date('2024-01-14T14:20:00') },
    { id: 1003, subject: 'Email notifications not sending', status: 'Open', createdAt: new Date('2024-01-14T09:15:00') },
    { id: 1004, subject: 'Dashboard loading slow', status: 'In Progress', createdAt: new Date('2024-01-13T16:45:00') },
    { id: 1005, subject: 'User profile update bug', status: 'Closed', createdAt: new Date('2024-01-12T11:00:00') },
    { id: 1006, subject: 'API rate limit exceeded error', status: 'Open', createdAt: new Date('2024-01-12T08:30:00') },
    { id: 1007, subject: 'Password reset not working', status: 'In Progress', createdAt: new Date('2024-01-11T13:20:00') },
    { id: 1008, subject: 'Search functionality broken', status: 'Closed', createdAt: new Date('2024-01-10T15:00:00') },
    { id: 1009, subject: 'Dark mode not applying correctly', status: 'Open', createdAt: new Date('2024-01-09T10:00:00') },
    { id: 1010, subject: 'Export feature missing data', status: 'Closed', createdAt: new Date('2024-01-08T12:30:00') },
  ];

  get filteredTickets(): Ticket[] {
    if (this.selectedFilter === 'All') {
      return this.tickets;
    }
    return this.tickets.filter(ticket => ticket.status === this.selectedFilter);
  }

  get openTicketCount(): number {
    return this.tickets.filter(t => t.status === 'Open').length;
  }

  get inProgressTicketCount(): number {
    return this.tickets.filter(t => t.status === 'In Progress').length;
  }

  get closedTicketCount(): number {
    return this.tickets.filter(t => t.status === 'Closed').length;
  }

  getStatusClass(status: string): string {
    switch (status) {
      case 'Open':
        return 'bg-red-100 text-red-800 border-red-300';
      case 'In Progress':
        return 'bg-yellow-100 text-yellow-800 border-yellow-300';
      case 'Closed':
        return 'bg-green-100 text-green-800 border-green-300';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-300';
    }
  }

  formatDate(date: Date): string {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  setFilter(filter: 'All' | 'Open' | 'In Progress' | 'Closed') {
    this.selectedFilter = filter;
  }
}
