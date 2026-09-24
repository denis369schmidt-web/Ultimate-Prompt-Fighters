#include "PFUMatchWidget.h"

#include "PFUMatchGameMode.h"
#include "Blueprint/WidgetTree.h"
#include "Components/Button.h"
#include "Components/EditableTextBox.h"
#include "Components/HorizontalBox.h"
#include "Components/HorizontalBoxSlot.h"
#include "Components/ProgressBar.h"
#include "Components/TextBlock.h"
#include "Components/VerticalBox.h"
#include "Components/VerticalBoxSlot.h"
#include "GameFramework/PlayerController.h"

void UPFUMatchWidget::NativeConstruct()
{
    Super::NativeConstruct();
    if (WidgetTree->RootWidget) return;
    UVerticalBox* Root = WidgetTree->ConstructWidget<UVerticalBox>(UVerticalBox::StaticClass(), TEXT("Root"));
    WidgetTree->RootWidget = Root;

    UTextBlock* Title = WidgetTree->ConstructWidget<UTextBlock>();
    Title->SetText(FText::FromString(TEXT("PROMPT FIGHTER ULTIMATE")));
    Root->AddChildToVerticalBox(Title);

    PlayerOnePrompt = WidgetTree->ConstructWidget<UEditableTextBox>();
    PlayerOnePrompt->SetText(FText::FromString(TEXT("blitzschneller Schattenninja mit elektrischen Klingen")));
    Root->AddChildToVerticalBox(PlayerOnePrompt);
    PlayerTwoPrompt = WidgetTree->ConstructWidget<UEditableTextBox>();
    PlayerTwoPrompt->SetText(FText::FromString(TEXT("gepanzerter Lavagolem mit brennenden Faeusten")));
    Root->AddChildToVerticalBox(PlayerTwoPrompt);

    UHorizontalBox* Buttons = WidgetTree->ConstructWidget<UHorizontalBox>();
    Root->AddChildToVerticalBox(Buttons);
    UButton* ManualButton = WidgetTree->ConstructWidget<UButton>();
    UTextBlock* ManualLabel = WidgetTree->ConstructWidget<UTextBlock>();
    ManualLabel->SetText(FText::FromString(TEXT("Lokaler Versus")));
    ManualButton->AddChild(ManualLabel);
    ManualButton->OnClicked.AddDynamic(this, &UPFUMatchWidget::StartManual);
    Buttons->AddChildToHorizontalBox(ManualButton);
    UButton* AIButton = WidgetTree->ConstructWidget<UButton>();
    UTextBlock* AILabel = WidgetTree->ConstructWidget<UTextBlock>();
    AILabel->SetText(FText::FromString(TEXT("Agentenkampf")));
    AIButton->AddChild(AILabel);
    AIButton->OnClicked.AddDynamic(this, &UPFUMatchWidget::StartAutonomous);
    Buttons->AddChildToHorizontalBox(AIButton);
    UButton* RestartButton = WidgetTree->ConstructWidget<UButton>();
    UTextBlock* RestartLabel = WidgetTree->ConstructWidget<UTextBlock>();
    RestartLabel->SetText(FText::FromString(TEXT("Neustart")));
    RestartButton->AddChild(RestartLabel);
    RestartButton->OnClicked.AddDynamic(this, &UPFUMatchWidget::Restart);
    Buttons->AddChildToHorizontalBox(RestartButton);

    PlayerOneHealth = WidgetTree->ConstructWidget<UProgressBar>();
    PlayerOneHealth->SetFillColorAndOpacity(FLinearColor(0.0f, 0.8f, 1.0f));
    Root->AddChildToVerticalBox(PlayerOneHealth);
    PlayerTwoHealth = WidgetTree->ConstructWidget<UProgressBar>();
    PlayerTwoHealth->SetFillColorAndOpacity(FLinearColor(1.0f, 0.12f, 0.02f));
    Root->AddChildToVerticalBox(PlayerTwoHealth);
    TimerText = WidgetTree->ConstructWidget<UTextBlock>();
    ResultText = WidgetTree->ConstructWidget<UTextBlock>();
    Root->AddChildToVerticalBox(TimerText);
    Root->AddChildToVerticalBox(ResultText);
}

void UPFUMatchWidget::Start(bool bAutonomous)
{
    if (APFUMatchGameMode* Match = GetWorld()->GetAuthGameMode<APFUMatchGameMode>())
        Match->StartMatchFromPrompts(PlayerOnePrompt->GetText().ToString(), PlayerTwoPrompt->GetText().ToString(), bAutonomous);
    if (APlayerController* Controller = GetOwningPlayer())
    {
        FInputModeGameAndUI Mode;
        Mode.SetHideCursorDuringCapture(false);
        Controller->SetInputMode(Mode);
        Controller->bShowMouseCursor = true;
    }
}

void UPFUMatchWidget::StartManual() { Start(false); }
void UPFUMatchWidget::StartAutonomous() { Start(true); }
void UPFUMatchWidget::Restart() { if (APFUMatchGameMode* Match = GetWorld()->GetAuthGameMode<APFUMatchGameMode>()) Match->RestartCurrentMatch(); }

void UPFUMatchWidget::UpdateMatch(float P1Health, float P2Health, float RemainingTime, const FString& Result)
{
    if (PlayerOneHealth) PlayerOneHealth->SetPercent(FMath::Clamp(P1Health, 0.0f, 1.0f));
    if (PlayerTwoHealth) PlayerTwoHealth->SetPercent(FMath::Clamp(P2Health, 0.0f, 1.0f));
    if (TimerText) TimerText->SetText(FText::FromString(FString::Printf(TEXT("Zeit: %02d"), FMath::CeilToInt(RemainingTime))));
    if (ResultText) ResultText->SetText(FText::FromString(Result));
}
