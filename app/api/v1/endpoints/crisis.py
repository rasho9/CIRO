from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from pydantic import BaseModel, Field
from typing import List

from ...models.schemas import ReportRequest, ReportResponse
from ...agents.signal_intake_agent import SignalIntakeAgent
from ...agents.nlp_detection_agent import NLPDetectionAgent
from ...agents.verification_agent import VerificationAgent
from ...agents.decision_planning_agent import DecisionPlanningAgent
from ...agents.simulation_agent import SimulationAgent
from ...agents.outcome_evaluation_agent import OutcomeEvaluationAgent
from ...repositories.firebase_repository import FirebaseRepository

router = APIRouter()

# Dependency injection (simple singleton for demo)

def get_signal_agent() -> SignalIntakeAgent:
    return SignalIntakeAgent()

def get_nlp_agent() -> NLPDetectionAgent:
    return NLPDetectionAgent()

def get_verification_agent() -> VerificationAgent:
    return VerificationAgent()

def get_decision_agent() -> DecisionPlanningAgent:
    return DecisionPlanningAgent()

def get_simulation_agent() -> SimulationAgent:
    return SimulationAgent()

def get_outcome_agent() -> OutcomeEvaluationAgent:
    return OutcomeEvaluationAgent()

def get_firebase_repo() -> FirebaseRepository:
    return FirebaseRepository()

@router.post("/report", response_model=ReportResponse)
async def report_crisis(
    request: ReportRequest,
    background: BackgroundTasks,
    signal_agent: SignalIntakeAgent = Depends(get_signal_agent),
    nlp_agent: NLPDetectionAgent = Depends(get_nlp_agent),
    verification_agent: VerificationAgent = Depends(get_verification_agent),
    decision_agent: DecisionPlanningAgent = Depends(get_decision_agent),
    simulation_agent: SimulationAgent = Depends(get_simulation_agent),
    outcome_agent: OutcomeEvaluationAgent = Depends(get_outcome_agent),
    repo: FirebaseRepository = Depends(get_firebase_repo),
):
    """Main orchestration endpoint.
    1️⃣ Signal Intake – enrich raw report with metadata (timestamp, location).
    2️⃣ NLP Detection – classify event, language, severity.
    3️⃣ Verification – simple rule‑based confidence boost.
    4️⃣ Decision Planning – generate recommended actions via Gemini.
    5️⃣ Simulation – mock traffic / dispatch simulation.
    6️⃣ Outcome Evaluation – produces outcome metrics (placeholder).
    The heavy work is scheduled in BackgroundTasks to keep the HTTP response fast.
    """
    # Step 1 – intake
    enriched = await signal_agent.process(request)
    # Step 2 – NLP
    detection = await nlp_agent.process(enriched)
    # Step 3 – verification
    verified = await verification_agent.process(detection)
    # Step 4 – planning
    plan = await decision_agent.process(verified)
    # Step 5 – simulation (runs in background)
    background.add_task(simulation_agent.run, plan)
    # Step 6 – outcome evaluation (placeholder, also background)
    background.add_task(outcome_agent.run, plan)

    # Persist incident (firestore)
    await repo.save_incident(plan)

    return ReportResponse(
        event=plan.event_type,
        severity=plan.severity,
        confidence=plan.confidence,
        recommended_actions=plan.actions,
    )
