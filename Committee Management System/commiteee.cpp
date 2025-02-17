#include <iostream>
#include <string>

using namespace std;

class Member {
public:
    int id;
    string name;
    double totalContributed;
    double totalReceived;

    // Default constructor
    Member() : id(0), name("Unknown"), totalContributed(0), totalReceived(0) {}

    // Parameterized constructor (used when adding a member manually)
    Member(int id, string name) : id(id), name(name), totalContributed(0), totalReceived(0) {}
};

class CommitteeManagementSystem {
private:
    Member* members;           // Pointer to dynamically allocated array of members
    int memberCount;           // Total number of members
    double fixedContribution;  // Fixed contribution amount each member gives each month
    int currentMemberIndex;    // Index of the member who will receive the funds

public:
    CommitteeManagementSystem(int maxMembers, double contribution) : memberCount(0), fixedContribution(contribution), currentMemberIndex(0) {
        members = new Member[maxMembers]; // Dynamically allocate memory for maxMembers
    }

    ~CommitteeManagementSystem() {
        delete[] members; // Clean up memory after usage
    }

    // Add a new member to the committee
    void addMember() {
        int id = memberCount + 1;  // Auto-generate ID based on the number of members
        string name;
        cout << "Enter member name: ";
        cin.ignore();
        getline(cin, name);
        members[memberCount] = Member(id, name);
        memberCount++;
        cout << "Member added successfully with ID " << id << ".\n";
    }

    // View all members
    void viewMembers() {
        if (memberCount == 0) {
            cout << "No members in the committee.\n";
            return;
        }

        cout << "\nMembers in the Committee:\n";
        for (int i = 0; i < memberCount; ++i) {
            cout << "ID: " << members[i].id << ", Name: " << members[i].name
                 << ", Total Contributed: " << members[i].totalContributed
                 << ", Total Received: " << members[i].totalReceived << endl;
        }
    }

    // Collect contributions for the month from all members
    void collectContributions() {
        if (memberCount == 0) {
            cout << "No members to collect contributions from.\n";
            return;
        }

        // Collect contributions from all members
        for (int i = 0; i < memberCount; ++i) {
            members[i].totalContributed += fixedContribution;
            cout << "Member " << members[i].name << " contributed " << fixedContribution << " units.\n";
        }
    }

    // Distribute collected funds to one member, cyclically
    void distributeFunds() {
        if (memberCount == 0) {
            cout << "No members to distribute funds to.\n";
            return;
        }

        // Calculate total collected funds
        double totalFunds = fixedContribution * memberCount;

        // Distribute the total funds to the current member
        Member& recipient = members[currentMemberIndex];
        recipient.totalReceived += totalFunds;
        cout << "Funds of " << totalFunds << " units distributed to " << recipient.name << " (ID: " << recipient.id << ").\n";

        // Move to the next member for the next distribution
        currentMemberIndex = (currentMemberIndex + 1) % memberCount;

        // Check if all members have received their share
        bool allReceived = true;
        for (int i = 0; i < memberCount; ++i) {
            if (members[i].totalReceived == 0) {
                allReceived = false;
                break;
            }
        }

        if (allReceived) {
            cout << "\nAll members have received their funds for this cycle.\n";
        }
    }

    // Menu to interact with the system
    void menu() {
        int choice;
        do {
            cout << "\n--- Committee Management System ---\n";
            cout << "1. Add Member\n";
            cout << "2. View Members\n";
            cout << "3. Collect Contributions\n";
            cout << "4. Distribute Funds\n";
            cout << "5. Exit\n";
            cout << "Enter your choice: ";
            cin >> choice;

            switch (choice) {
                case 1:
                    addMember();
                    break;
                case 2:
                    viewMembers();
                    break;
                case 3:
                    collectContributions();
                    break;
                case 4:
                    distributeFunds();
                    break;
                case 5:
                    cout << "Exiting system.\n";
                    break;
                default:
                    cout << "Invalid choice. Please try again.\n";
            }
        } while (choice != 5);
    }
};

int main() {
    int maxMembers;
    double fixedContribution;

    cout << "Enter the maximum number of members: ";
    cin >> maxMembers;
    cout << "Enter fixed monthly contribution amount for each member: ";
    cin >> fixedContribution;

    // Create the committee management system object
    CommitteeManagementSystem cms(maxMembers, fixedContribution);
    cms.menu();
    return 0;
}
