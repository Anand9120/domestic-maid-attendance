names = [
    ('01_stakeholders', 'System Stakeholders & User Personas Diagram'),
    ('02_operational_lifecycle', 'End-to-End Operational Lifecycle Flowchart'),
    ('03_household_calibration_seq', 'Household Setup & GPS Calibration Sequence'),
    ('04_maid_onboarding_seq', 'Maid Onboarding & Household Linking Sequence'),
    ('05_attendance_pipeline_flow', 'Zero-Touch Attendance & Anti-Fraud Verification Pipeline'),
    ('06_multi_household_radar_state', 'Multi-Household Society Auto-Switching Radar State Machine'),
    ('07_offline_buffer_sync', 'Offline-First Hive DB Buffer Architecture'),
    ('08_payroll_calculation_seq', 'Monthly Payroll & Pro-Rata Deduction Calculation Sequence'),
    ('09_upi_settlement_seq', 'NPCI UPI Deep-Link Digital Settlement Sequence'),
    ('10_technical_architecture', 'Full-Stack Technical Architecture Diagram'),
    ('11_database_er_diagram', 'MySQL 8.0 Relational Entity-Relationship Diagram')
]

with open('docs/SAHAYIKA_RFP_FUNCTIONAL_FLOW.md', 'r') as f:
    content = f.read()

# Strip any existing image tags if already present
import re
content = re.sub(r'!\[.*?\]\((images/diagrams/|/home/apj/.*?/diagrams/).*?\.png\)\n\n', '', content)

fence = '```' + 'mermaid'
parts = content.split(fence)
new_parts = [parts[0]]

for idx, p in enumerate(parts[1:]):
    name, title = names[idx]
    image_tag = f'\n![{title}](images/diagrams/{name}.png)\n\n'
    new_parts.append(image_tag + fence + p)

with open('docs/SAHAYIKA_RFP_FUNCTIONAL_FLOW.md', 'w') as f:
    f.write(''.join(new_parts))

art_path = '/home/apj/.gemini/antigravity-ide/brain/38fccfd9-7c4f-47aa-9f96-d3e1241b2ca3/sahayika_rfp_functional_flow.md'
art_parts = [parts[0]]
for idx, p in enumerate(parts[1:]):
    name, title = names[idx]
    abs_image_tag = f'\n![{title}](/home/apj/.gemini/antigravity-ide/brain/38fccfd9-7c4f-47aa-9f96-d3e1241b2ca3/diagrams/{name}.png)\n\n'
    art_parts.append(abs_image_tag + fence + p)

with open(art_path, 'w') as f:
    f.write(''.join(art_parts))

print('Successfully embedded diagram images!')
